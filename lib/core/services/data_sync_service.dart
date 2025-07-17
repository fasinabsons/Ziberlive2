import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../error/failures.dart';
import '../utils/result.dart';
import '../../data/datasources/local/database_helper.dart';
import 'p2p_sync_service.dart';
import 'bluetooth_messaging_service.dart';
import 'ad_service.dart';

enum SyncOperation {
  create,
  update,
  delete,
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict,
}

class DataSyncService {
  final DatabaseHelper _databaseHelper;
  final P2PSyncService _p2pService;
  final BluetoothMessagingService _bluetoothService;
  final AdService _adService;
  
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  final StreamController<SyncProgress> _syncProgressController = StreamController<SyncProgress>.broadcast();
  final StreamController<List<SyncConflict>> _conflictsController = StreamController<List<SyncConflict>>.broadcast();
  
  final List<SyncQueueItem> _syncQueue = [];
  final List<SyncConflict> _pendingConflicts = [];
  
  SyncStatus _currentStatus = SyncStatus.idle;
  Timer? _syncTimer;
  String? _deviceId;
  String? _apartmentId;

  // Streams
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;
  Stream<List<SyncConflict>> get conflictsStream => _conflictsController.stream;

  // Getters
  SyncStatus get currentStatus => _currentStatus;
  List<SyncQueueItem> get queuedItems => List.unmodifiable(_syncQueue);
  List<SyncConflict> get pendingConflicts => List.unmodifiable(_pendingConflicts);

  DataSyncService(this._databaseHelper, this._p2pService, this._bluetoothService, this._adService);

  Future<Result<void>> initialize(String deviceId, String apartmentId) async {
    try {
      _deviceId = deviceId;
      _apartmentId = apartmentId;

      // Listen to P2P data stream
      _p2pService.dataStream.listen(_handleIncomingSyncData);
      
      // Listen to Bluetooth message stream for sync data
      _bluetoothService.messageStream
          .where((message) => message.type == MessageType.sync)
          .listen((message) {
        try {
          final syncData = jsonDecode(message.content) as Map<String, dynamic>;
          final payload = SyncPayload.fromJson(syncData);
          _handleIncomingSyncData(payload);
        } catch (e) {
          print('Error processing Bluetooth sync message: $e');
        }
      });

      // Start periodic sync
      _startPeriodicSync();

      _updateSyncStatus(SyncStatus.idle);
      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to initialize sync service: $e'));
    }
  }

  Future<Result<void>> queueForSync({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final queueItem = SyncQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableName: tableName,
        recordId: recordId,
        operation: operation,
        data: data,
        timestamp: DateTime.now(),
        deviceId: _deviceId!,
        retryCount: 0,
      );

      _syncQueue.add(queueItem);

      // Log to sync_log table
      await _logSyncOperation(queueItem);

      // Trigger immediate sync if connected
      if (_p2pService.connectedDevices.isNotEmpty || 
          _bluetoothService.connections.isNotEmpty) {
        _triggerSync();
      }

      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to queue sync item: $e'));
    }
  }

  Future<Result<void>> performSync() async {
    if (_currentStatus == SyncStatus.syncing) {
      return const Error(SyncFailure(message: 'Sync already in progress'));
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);
      
      // Show ads during sync operation (exactly 2 ads per sync)
      await _adService.showSyncAds();
      
      final progress = SyncProgress(
        totalItems: _syncQueue.length,
        processedItems: 0,
        conflicts: 0,
        errors: 0,
      );
      _syncProgressController.add(progress);

      // Process sync queue
      for (int i = 0; i < _syncQueue.length; i++) {
        final item = _syncQueue[i];
        
        try {
          await _syncItem(item);
          progress.processedItems++;
        } catch (e) {
          progress.errors++;
          print('Error syncing item ${item.id}: $e');
        }
        
        _syncProgressController.add(progress);
      }

      // Clear successfully synced items
      _syncQueue.removeWhere((item) => item.retryCount < 3);

      _updateSyncStatus(_pendingConflicts.isEmpty ? SyncStatus.success : SyncStatus.conflict);
      return const Success(null);
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      return Error(SyncFailure(message: 'Sync failed: $e'));
    }
  }

  Future<Result<void>> resolveConflict(String conflictId, ConflictResolution resolution) async {
    try {
      final conflictIndex = _pendingConflicts.indexWhere((c) => c.id == conflictId);
      if (conflictIndex == -1) {
        return const Error(SyncFailure(message: 'Conflict not found'));
      }

      final conflict = _pendingConflicts[conflictIndex];
      
      switch (resolution) {
        case ConflictResolution.useLocal:
          await _applyLocalData(conflict);
          break;
        case ConflictResolution.useRemote:
          await _applyRemoteData(conflict);
          break;
        case ConflictResolution.merge:
          await _mergeData(conflict);
          break;
      }

      _pendingConflicts.removeAt(conflictIndex);
      _conflictsController.add(_pendingConflicts);

      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to resolve conflict: $e'));
    }
  }

  Future<void> _syncItem(SyncQueueItem item) async {
    final payload = SyncPayload(
      dataType: item.tableName,
      operation: item.operation.name,
      data: item.data,
      timestamp: item.timestamp,
      deviceId: item.deviceId,
      checksum: _generateChecksum(item.data),
    );

    // Send via P2P if available
    if (_p2pService.connectedDevices.isNotEmpty) {
      await _p2pService.sendData(payload);
    }

    // Send via Bluetooth if available
    if (_bluetoothService.connections.isNotEmpty) {
      await _bluetoothService.sendSyncData(payload.toJson());
    }
  }

  void _handleIncomingSyncData(SyncPayload payload) async {
    try {
      // Verify checksum
      final expectedChecksum = _generateChecksum(payload.data);
      if (payload.checksum != expectedChecksum) {
        print('Checksum mismatch for sync payload');
        return;
      }

      // Check for conflicts
      final hasConflict = await _checkForConflict(payload);
      if (hasConflict) {
        await _handleConflict(payload);
        return;
      }

      // Apply the sync data
      await _applySyncData(payload);
      
      // Mark as synced in log
      await _markAsSynced(payload);
    } catch (e) {
      print('Error handling incoming sync data: $e');
    }
  }

  Future<bool> _checkForConflict(SyncPayload payload) async {
    try {
      final db = await _databaseHelper.database;
      
      // Check if record exists locally
      final localRecords = await db.query(
        payload.dataType,
        where: 'id = ?',
        whereArgs: [payload.data['id']],
      );

      if (localRecords.isEmpty) {
        return false; // No conflict for new records
      }

      final localRecord = localRecords.first;
      final localTimestamp = DateTime.parse(localRecord['last_sync_at'] as String);
      
      // Check if local version is newer
      return localTimestamp.isAfter(payload.timestamp);
    } catch (e) {
      print('Error checking for conflict: $e');
      return false;
    }
  }

  Future<void> _handleConflict(SyncPayload payload) async {
    try {
      final db = await _databaseHelper.database;
      final localRecords = await db.query(
        payload.dataType,
        where: 'id = ?',
        whereArgs: [payload.data['id']],
      );

      if (localRecords.isNotEmpty) {
        final conflict = SyncConflict(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tableName: payload.dataType,
          recordId: payload.data['id'],
          localData: localRecords.first,
          remoteData: payload.data,
          localTimestamp: DateTime.parse(localRecords.first['last_sync_at'] as String),
          remoteTimestamp: payload.timestamp,
          remoteDeviceId: payload.deviceId,
        );

        _pendingConflicts.add(conflict);
        _conflictsController.add(_pendingConflicts);
      }
    } catch (e) {
      print('Error handling conflict: $e');
    }
  }

  Future<void> _applySyncData(SyncPayload payload) async {
    try {
      final db = await _databaseHelper.database;
      
      switch (SyncOperation.values.firstWhere((e) => e.name == payload.operation)) {
        case SyncOperation.create:
        case SyncOperation.update:
          await db.insert(
            payload.dataType,
            payload.data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          break;
        case SyncOperation.delete:
          await db.delete(
            payload.dataType,
            where: 'id = ?',
            whereArgs: [payload.data['id']],
          );
          break;
      }
    } catch (e) {
      print('Error applying sync data: $e');
    }
  }

  Future<void> _applyLocalData(SyncConflict conflict) async {
    // Keep local data, broadcast to other devices
    await queueForSync(
      tableName: conflict.tableName,
      recordId: conflict.recordId,
      operation: SyncOperation.update,
      data: conflict.localData,
    );
  }

  Future<void> _applyRemoteData(SyncConflict conflict) async {
    // Apply remote data locally
    final payload = SyncPayload(
      dataType: conflict.tableName,
      operation: SyncOperation.update.name,
      data: conflict.remoteData,
      timestamp: conflict.remoteTimestamp,
      deviceId: conflict.remoteDeviceId,
      checksum: _generateChecksum(conflict.remoteData),
    );
    
    await _applySyncData(payload);
  }

  Future<void> _mergeData(SyncConflict conflict) async {
    // Simple merge strategy - combine non-conflicting fields
    final mergedData = Map<String, dynamic>.from(conflict.localData);
    
    // Use remote timestamp if it's newer
    if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
      mergedData['last_sync_at'] = conflict.remoteTimestamp.toIso8601String();
    }
    
    // Apply merged data
    await queueForSync(
      tableName: conflict.tableName,
      recordId: conflict.recordId,
      operation: SyncOperation.update,
      data: mergedData,
    );
  }

  Future<void> _logSyncOperation(SyncQueueItem item) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('sync_log', {
        'id': item.id,
        'table_name': item.tableName,
        'record_id': item.recordId,
        'operation': item.operation.name,
        'timestamp': item.timestamp.toIso8601String(),
        'device_id': item.deviceId,
        'synced': 0,
        'conflict_resolved': 1,
      });
    } catch (e) {
      print('Error logging sync operation: $e');
    }
  }

  Future<void> _markAsSynced(SyncPayload payload) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'sync_log',
        {'synced': 1},
        where: 'record_id = ? AND table_name = ?',
        whereArgs: [payload.data['id'], payload.dataType],
      );
    } catch (e) {
      print('Error marking as synced: $e');
    }
  }

  String _generateChecksum(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_syncQueue.isNotEmpty) {
        _triggerSync();
      }
    });
  }

  void _triggerSync() {
    if (_currentStatus != SyncStatus.syncing) {
      performSync();
    }
  }

  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
    _conflictsController.close();
  }
}

class SyncQueueItem {
  final String id;
  final String tableName;
  final String recordId;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String deviceId;
  int retryCount;

  SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.data,
    required this.timestamp,
    required this.deviceId,
    required this.retryCount,
  });
}

class SyncProgress {
  int totalItems;
  int processedItems;
  int conflicts;
  int errors;

  SyncProgress({
    required this.totalItems,
    required this.processedItems,
    required this.conflicts,
    required this.errors,
  });

  double get progress => totalItems > 0 ? processedItems / totalItems : 0.0;
}

class SyncConflict {
  final String id;
  final String tableName;
  final String recordId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;
  final String remoteDeviceId;

  SyncConflict({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.remoteDeviceId,
  });
}

enum ConflictResolution {
  useLocal,
  useRemote,
  merge,
}