import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/di/injection_container.dart';

class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  late DataSyncService _syncService;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _syncService = getIt<DataSyncService>();
    _loadLastSyncTime();
  }

  void _loadLastSyncTime() {
    // TODO: Load from shared preferences or database
    setState(() {
      _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _syncService.syncStatusStream,
      initialData: _syncService.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        if (widget.showDetails) {
          return _buildDetailedStatus(status);
        } else {
          return _buildCompactStatus(status);
        }
      },
    );
  }

  Widget _buildCompactStatus(SyncStatus status) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(status),
            const SizedBox(width: 6),
            Text(
              _getStatusText(status),
              style: TextStyle(
                color: _getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatus(SyncStatus status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != SyncStatus.syncing)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _triggerManualSync,
                    tooltip: 'Manual Sync',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLastSyncInfo(),
            if (status == SyncStatus.syncing) ...[
              const SizedBox(height: 12),
              _buildSyncProgress(),
            ],
            if (status == SyncStatus.conflict) ...[
              const SizedBox(height: 12),
              _buildConflictInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icon(
          Icons.sync,
          color: _getStatusColor(status),
          size: 16,
        );
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_getStatusColor(status)),
          ),
        );
      case SyncStatus.success:
        return Icon(
          Icons.check_circle,
          color: _getStatusColor(status),
          size: 16,
        );
      case SyncStatus.error:
        return Icon(
          Icons.error,
          color: _getStatusColor(status),
          size: 16,
        );
      case SyncStatus.conflict:
        return Icon(
          Icons.warning,
          color: _getStatusColor(status),
          size: 16,
        );
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.conflict:
        return Colors.orange;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Ready to sync';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync failed';
      case SyncStatus.conflict:
        return 'Conflicts found';
    }
  }

  Widget _buildLastSyncInfo() {
    if (_lastSyncTime == null) {
      return const Text(
        'Never synced',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      );
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    String timeText;
    if (difference.inMinutes < 1) {
      timeText = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      timeText = '${difference.inHours} hours ago';
    } else {
      timeText = '${difference.inDays} days ago';
    }

    return Text(
      'Last synced: $timeText',
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );
  }

  Widget _buildSyncProgress() {
    return StreamBuilder<SyncProgress>(
      stream: _syncService.syncProgressStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final progress = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              'Syncing ${progress.processedItems}/${progress.totalItems} items',
              style: const TextStyle(fontSize: 12),
            ),
            if (progress.errors > 0)
              Text(
                '${progress.errors} errors',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConflictInfo() {
    return StreamBuilder<List<SyncConflict>>(
      stream: _syncService.conflictsStream,
      builder: (context, snapshot) {
        final conflicts = snapshot.data ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${conflicts.length} conflicts need resolution',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showConflictResolution,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Resolve Conflicts',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  void _triggerManualSync() {
    _syncService.performSync();
    setState(() {
      _lastSyncTime = DateTime.now();
    });
  }

  void _showConflictResolution() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConflictResolutionPage(),
      ),
    );
  }
}

class ConflictResolutionPage extends StatelessWidget {
  const ConflictResolutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = getIt<DataSyncService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Sync Conflicts'),
      ),
      body: StreamBuilder<List<SyncConflict>>(
        stream: syncService.conflictsStream,
        builder: (context, snapshot) {
          final conflicts = snapshot.data ?? [];

          if (conflicts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No conflicts to resolve',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('All data is synchronized'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _buildConflictCard(context, conflict, syncService);
            },
          );
        },
      ),
    );
  }

  Widget _buildConflictCard(BuildContext context, SyncConflict conflict, DataSyncService syncService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${conflict.tableName} - ${conflict.recordId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Local: ${conflict.localTimestamp.toString()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Remote: ${conflict.remoteTimestamp.toString()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveConflict(
                      syncService,
                      conflict.id,
                      ConflictResolution.useLocal,
                    ),
                    child: const Text('Use Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveConflict(
                      syncService,
                      conflict.id,
                      ConflictResolution.useRemote,
                    ),
                    child: const Text('Use Remote'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolveConflict(
                      syncService,
                      conflict.id,
                      ConflictResolution.merge,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Merge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resolveConflict(DataSyncService syncService, String conflictId, ConflictResolution resolution) {
    syncService.resolveConflict(conflictId, resolution);
  }
}