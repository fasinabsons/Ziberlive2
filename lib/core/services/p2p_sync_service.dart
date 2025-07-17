import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../error/failures.dart';
import '../utils/result.dart';

enum ConnectionStatus {
  disconnected,
  discovering,
  advertising,
  connecting,
  connected,
  error,
}

enum DeviceType {
  advertiser,
  discoverer,
}

class P2PSyncService {
  static const String _serviceId = 'ziberlive_sync';
  static const String _strategy = Strategy.P2P_CLUSTER;
  
  final StreamController<ConnectionStatus> _statusController = StreamController<ConnectionStatus>.broadcast();
  final StreamController<List<DiscoveredDevice>> _devicesController = StreamController<List<DiscoveredDevice>>.broadcast();
  final StreamController<SyncPayload> _dataController = StreamController<SyncPayload>.broadcast();
  
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  final List<DiscoveredDevice> _discoveredDevices = [];
  final Map<String, ConnectedDevice> _connectedDevices = {};
  
  String? _localDeviceId;
  String? _apartmentId;

  // Streams
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;
  Stream<SyncPayload> get dataStream => _dataController.stream;

  // Getters
  ConnectionStatus get currentStatus => _currentStatus;
  List<DiscoveredDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  List<ConnectedDevice> get connectedDevices => _connectedDevices.values.toList();

  Future<Result<void>> initialize(String apartmentId, String deviceId) async {
    try {
      _apartmentId = apartmentId;
      _localDeviceId = deviceId;
      
      // Request permissions
      final permissionStatus = await Nearby().askLocationPermission();
      if (!permissionStatus) {
        return const Error(PermissionFailure(
          message: 'Location permission is required for P2P sync',
        ));
      }

      _updateStatus(ConnectionStatus.disconnected);
      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to initialize P2P service: $e'));
    }
  }

  Future<Result<void>> startAdvertising() async {
    try {
      if (_apartmentId == null || _localDeviceId == null) {
        return const Error(SyncFailure(message: 'P2P service not initialized'));
      }

      _updateStatus(ConnectionStatus.advertising);

      final advertisingResult = await Nearby().startAdvertising(
        _localDeviceId!,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );

      if (!advertisingResult) {
        _updateStatus(ConnectionStatus.error);
        return const Error(SyncFailure(message: 'Failed to start advertising'));
      }

      return const Success(null);
    } catch (e) {
      _updateStatus(ConnectionStatus.error);
      return Error(SyncFailure(message: 'Error starting advertising: $e'));
    }
  }

  Future<Result<void>> startDiscovery() async {
    try {
      if (_apartmentId == null || _localDeviceId == null) {
        return const Error(SyncFailure(message: 'P2P service not initialized'));
      }

      _updateStatus(ConnectionStatus.discovering);
      _discoveredDevices.clear();

      final discoveryResult = await Nearby().startDiscovery(
        _localDeviceId!,
        _strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
        serviceId: _serviceId,
      );

      if (!discoveryResult) {
        _updateStatus(ConnectionStatus.error);
        return const Error(SyncFailure(message: 'Failed to start discovery'));
      }

      return const Success(null);
    } catch (e) {
      _updateStatus(ConnectionStatus.error);
      return Error(SyncFailure(message: 'Error starting discovery: $e'));
    }
  }

  Future<Result<void>> connectToDevice(String endpointId) async {
    try {
      _updateStatus(ConnectionStatus.connecting);

      final connectionResult = await Nearby().requestConnection(
        _localDeviceId!,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      if (!connectionResult) {
        _updateStatus(ConnectionStatus.error);
        return const Error(ConnectionFailure(message: 'Failed to request connection'));
      }

      return const Success(null);
    } catch (e) {
      _updateStatus(ConnectionStatus.error);
      return Error(ConnectionFailure(message: 'Error connecting to device: $e'));
    }
  }

  Future<Result<void>> sendData(SyncPayload payload) async {
    try {
      if (_connectedDevices.isEmpty) {
        return const Error(ConnectionFailure(message: 'No connected devices'));
      }

      final jsonData = jsonEncode(payload.toJson());
      final bytes = Uint8List.fromList(utf8.encode(jsonData));

      // Send to all connected devices
      for (final deviceId in _connectedDevices.keys) {
        await Nearby().sendBytesPayload(deviceId, bytes);
      }

      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to send data: $e'));
    }
  }

  Future<void> disconnect() async {
    try {
      await Nearby().stopAllEndpoints();
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();
      
      _connectedDevices.clear();
      _discoveredDevices.clear();
      _updateStatus(ConnectionStatus.disconnected);
    } catch (e) {
      print('Error during disconnect: $e');
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _devicesController.close();
    _dataController.close();
  }

  // Private methods
  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _onEndpointFound(String endpointId, String endpointName, String serviceId) {
    // Parse device info from endpoint name
    try {
      final deviceInfo = jsonDecode(endpointName) as Map<String, dynamic>;
      final device = DiscoveredDevice(
        endpointId: endpointId,
        deviceId: deviceInfo['deviceId'] ?? endpointId,
        deviceName: deviceInfo['deviceName'] ?? 'Unknown Device',
        apartmentId: deviceInfo['apartmentId'] ?? '',
        lastSeen: DateTime.now(),
      );

      // Only add devices from the same apartment
      if (device.apartmentId == _apartmentId) {
        _discoveredDevices.add(device);
        _devicesController.add(_discoveredDevices);
      }
    } catch (e) {
      print('Error parsing device info: $e');
    }
  }

  void _onEndpointLost(String endpointId) {
    _discoveredDevices.removeWhere((device) => device.endpointId == endpointId);
    _devicesController.add(_discoveredDevices);
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo connectionInfo) {
    // Auto-accept connections from same apartment
    // In production, you might want to show a confirmation dialog
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      final device = _discoveredDevices.firstWhere(
        (d) => d.endpointId == endpointId,
        orElse: () => DiscoveredDevice(
          endpointId: endpointId,
          deviceId: endpointId,
          deviceName: 'Unknown Device',
          apartmentId: _apartmentId ?? '',
          lastSeen: DateTime.now(),
        ),
      );

      _connectedDevices[endpointId] = ConnectedDevice(
        endpointId: endpointId,
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        connectedAt: DateTime.now(),
      );

      _updateStatus(ConnectionStatus.connected);
    } else {
      _connectedDevices.remove(endpointId);
      if (_connectedDevices.isEmpty) {
        _updateStatus(ConnectionStatus.disconnected);
      }
    }
  }

  void _onDisconnected(String endpointId) {
    _connectedDevices.remove(endpointId);
    if (_connectedDevices.isEmpty) {
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    try {
      if (payload.type == PayloadType.BYTES) {
        final jsonString = utf8.decode(payload.bytes!);
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        final syncPayload = SyncPayload.fromJson(data);
        _dataController.add(syncPayload);
      }
    } catch (e) {
      print('Error processing received payload: $e');
    }
  }
}

class DiscoveredDevice {
  final String endpointId;
  final String deviceId;
  final String deviceName;
  final String apartmentId;
  final DateTime lastSeen;

  DiscoveredDevice({
    required this.endpointId,
    required this.deviceId,
    required this.deviceName,
    required this.apartmentId,
    required this.lastSeen,
  });
}

class ConnectedDevice {
  final String endpointId;
  final String deviceId;
  final String deviceName;
  final DateTime connectedAt;

  ConnectedDevice({
    required this.endpointId,
    required this.deviceId,
    required this.deviceName,
    required this.connectedAt,
  });
}

class SyncPayload {
  final String dataType;
  final String operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String deviceId;
  final String checksum;

  SyncPayload({
    required this.dataType,
    required this.operation,
    required this.data,
    required this.timestamp,
    required this.deviceId,
    required this.checksum,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataType': dataType,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'checksum': checksum,
    };
  }

  factory SyncPayload.fromJson(Map<String, dynamic> json) {
    return SyncPayload(
      dataType: json['dataType'],
      operation: json['operation'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      checksum: json['checksum'],
    );
  }
}