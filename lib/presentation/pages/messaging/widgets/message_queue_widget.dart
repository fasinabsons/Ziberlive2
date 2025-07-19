import 'package:flutter/material.dart';
import '../../../../core/services/offline_message_service.dart';
import '../../../../core/services/bluetooth_messaging_service.dart';

class MessageQueueWidget extends StatelessWidget {
  final List<ChatMessage> queuedMessages;
  final VoidCallback? onRetryAll;
  final VoidCallback? onClearQueue;

  const MessageQueueWidget({
    Key? key,
    required this.queuedMessages,
    this.onRetryAll,
    this.onClearQueue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (queuedMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pending Messages',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${queuedMessages.length}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'These messages will be sent when connection is restored',
            style: TextStyle(
              color: Colors.orange[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetryAll,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearQueue,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange[700],
                    side: BorderSide(color: Colors.orange[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageStatusIndicator extends StatelessWidget {
  final MessageDeliveryStatus status;

  const MessageStatusIndicator({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getStatusTooltip(),
      child: Icon(
        _getStatusIcon(),
        size: 16,
        color: _getStatusColor(),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status.status) {
      case DeliveryStatus.queued:
        return Icons.schedule;
      case DeliveryStatus.sending:
        return Icons.sync;
      case DeliveryStatus.delivered:
        return Icons.done_all;
      case DeliveryStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    switch (status.status) {
      case DeliveryStatus.queued:
        return Colors.orange;
      case DeliveryStatus.sending:
        return Colors.blue;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusTooltip() {
    switch (status.status) {
      case DeliveryStatus.queued:
        return 'Message queued for delivery';
      case DeliveryStatus.sending:
        return 'Sending message...';
      case DeliveryStatus.delivered:
        return 'Message delivered';
      case DeliveryStatus.failed:
        return 'Failed to deliver message${status.lastError != null ? ': ${status.lastError}' : ''}';
    }
  }
}

class QueuedMessagesList extends StatelessWidget {
  final List<ChatMessage> queuedMessages;
  final Function(String)? onRetryMessage;
  final Function(String)? onRemoveMessage;

  const QueuedMessagesList({
    Key? key,
    required this.queuedMessages,
    this.onRetryMessage,
    this.onRemoveMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Queued Messages (${queuedMessages.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: queuedMessages.length,
            itemBuilder: (context, index) {
              final message = queuedMessages[index];
              return _buildQueuedMessageTile(context, message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueuedMessageTile(BuildContext context, ChatMessage message) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.orange.withOpacity(0.2),
        child: Icon(
          Icons.schedule,
          size: 16,
          color: Colors.orange[700],
        ),
      ),
      title: Text(
        message.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Queued ${_formatTime(message.timestamp)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'retry':
              onRetryMessage?.call(message.id);
              break;
            case 'remove':
              onRemoveMessage?.call(message.id);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'retry',
            child: Row(
              children: [
                Icon(Icons.refresh, size: 16),
                SizedBox(width: 8),
                Text('Retry'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete, size: 16),
                SizedBox(width: 8),
                Text('Remove'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}