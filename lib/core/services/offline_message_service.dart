import 'dart:convert';
import '../error/failures.dart';
import '../utils/result.dart';
import 'bluetooth_messaging_service.dart';

abstract class OfflineMessageService {
  Future<Result<void>> queueMessage(ChatMessage message);
  Future<Result<List<ChatMessage>>> getQueuedMessages();
  Future<Result<void>> markMessageAsDelivered(String messageId);
  Future<Result<void>> retryFailedMessages();
  Future<Result<void>> clearQueue();
  Future<Result<MessageDeliveryStatus>> getMessageStatus(String messageId);
}

class OfflineMessageServiceImpl implements OfflineMessageService {
  final BluetoothMessagingService _bluetoothService;
  final List<QueuedMessage> _messageQueue = [];
  final Map<String, MessageDeliveryStatus> _deliveryStatuses = {};
  
  OfflineMessageServiceImpl(this._bluetoothService);
  
  @override
  Future<Result<void>> queueMessage(ChatMessage message) async {
    try {
      final queuedMessage = QueuedMessage(
        message: message,
        queuedAt: DateTime.now(),
        retryCount: 0,
        status: MessageQueueStatus.pending,
      );
      
      _messageQueue.add(queuedMessage);
      _deliveryStatuses[message.id] = MessageDeliveryStatus(
        messageId: message.id,
        status: DeliveryStatus.queued,
        queuedAt: DateTime.now(),
      );
      
      // Try to send immediately if connected
      if (_bluetoothService.currentStatus == BluetoothConnectionStatus.connected) {
        await _attemptDelivery(queuedMessage);
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to queue message: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<ChatMessage>>> getQueuedMessages() async {
    try {
      final queuedMessages = _messageQueue
          .where((qm) => qm.status == MessageQueueStatus.pending)
          .map((qm) => qm.message)
          .toList();
      
      return Success(queuedMessages);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get queued messages: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> markMessageAsDelivered(String messageId) async {
    try {
      // Update queue status
      final queuedMessageIndex = _messageQueue.indexWhere(
        (qm) => qm.message.id == messageId,
      );
      
      if (queuedMessageIndex != -1) {
        _messageQueue[queuedMessageIndex] = _messageQueue[queuedMessageIndex].copyWith(
          status: MessageQueueStatus.delivered,
          deliveredAt: DateTime.now(),
        );
      }
      
      // Update delivery status
      _deliveryStatuses[messageId] = _deliveryStatuses[messageId]?.copyWith(
        status: DeliveryStatus.delivered,
        deliveredAt: DateTime.now(),
      ) ?? MessageDeliveryStatus(
        messageId: messageId,
        status: DeliveryStatus.delivered,
        deliveredAt: DateTime.now(),
      );
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to mark message as delivered: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> retryFailedMessages() async {
    try {
      final failedMessages = _messageQueue
          .where((qm) => qm.status == MessageQueueStatus.failed)
          .toList();
      
      for (final queuedMessage in failedMessages) {
        if (queuedMessage.retryCount < 3) { // Max 3 retries
          await _attemptDelivery(queuedMessage);
        }
      }
      
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to retry messages: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> clearQueue() async {
    try {
      _messageQueue.clear();
      _deliveryStatuses.clear();
      return Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to clear queue: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<MessageDeliveryStatus>> getMessageStatus(String messageId) async {
    try {
      final status = _deliveryStatuses[messageId];
      if (status != null) {
        return Success(status);
      } else {
        return Error(NotFoundFailure(message: 'Message status not found'));
      }
    } catch (e) {
      return Error(ServerFailure(message: 'Failed to get message status: ${e.toString()}'));
    }
  }
  
  // Process queued messages when connection is restored
  Future<void> processQueueOnConnection() async {
    if (_bluetoothService.currentStatus == BluetoothConnectionStatus.connected) {
      final pendingMessages = _messageQueue
          .where((qm) => qm.status == MessageQueueStatus.pending)
          .toList();
      
      for (final queuedMessage in pendingMessages) {
        await _attemptDelivery(queuedMessage);
        
        // Add delay between messages to avoid overwhelming the connection
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  
  // Private methods
  
  Future<void> _attemptDelivery(QueuedMessage queuedMessage) async {
    try {
      // Update status to sending
      final messageIndex = _messageQueue.indexOf(queuedMessage);
      if (messageIndex != -1) {
        _messageQueue[messageIndex] = queuedMessage.copyWith(
          status: MessageQueueStatus.sending,
        );
      }
      
      _deliveryStatuses[queuedMessage.message.id] = _deliveryStatuses[queuedMessage.message.id]?.copyWith(
        status: DeliveryStatus.sending,
        lastAttemptAt: DateTime.now(),
      ) ?? MessageDeliveryStatus(
        messageId: queuedMessage.message.id,
        status: DeliveryStatus.sending,
        lastAttemptAt: DateTime.now(),
      );
      
      // Attempt to send the message
      final result = await _bluetoothService.sendMessage(queuedMessage.message);
      
      result.fold(
        (failure) => _handleDeliveryFailure(queuedMessage, failure.message),
        (_) => _handleDeliverySuccess(queuedMessage),
      );
    } catch (e) {
      _handleDeliveryFailure(queuedMessage, e.toString());
    }
  }
  
  void _handleDeliverySuccess(QueuedMessage queuedMessage) {
    final messageIndex = _messageQueue.indexOf(queuedMessage);
    if (messageIndex != -1) {
      _messageQueue[messageIndex] = queuedMessage.copyWith(
        status: MessageQueueStatus.delivered,
        deliveredAt: DateTime.now(),
      );
    }
    
    _deliveryStatuses[queuedMessage.message.id] = _deliveryStatuses[queuedMessage.message.id]?.copyWith(
      status: DeliveryStatus.delivered,
      deliveredAt: DateTime.now(),
    ) ?? MessageDeliveryStatus(
      messageId: queuedMessage.message.id,
      status: DeliveryStatus.delivered,
      deliveredAt: DateTime.now(),
    );
  }
  
  void _handleDeliveryFailure(QueuedMessage queuedMessage, String error) {
    final newRetryCount = queuedMessage.retryCount + 1;
    final newStatus = newRetryCount >= 3 
        ? MessageQueueStatus.failed 
        : MessageQueueStatus.pending;
    
    final messageIndex = _messageQueue.indexOf(queuedMessage);
    if (messageIndex != -1) {
      _messageQueue[messageIndex] = queuedMessage.copyWith(
        status: newStatus,
        retryCount: newRetryCount,
        lastError: error,
      );
    }
    
    final deliveryStatus = newRetryCount >= 3 
        ? DeliveryStatus.failed 
        : DeliveryStatus.queued;
    
    _deliveryStatuses[queuedMessage.message.id] = _deliveryStatuses[queuedMessage.message.id]?.copyWith(
      status: deliveryStatus,
      retryCount: newRetryCount,
      lastError: error,
      lastAttemptAt: DateTime.now(),
    ) ?? MessageDeliveryStatus(
      messageId: queuedMessage.message.id,
      status: deliveryStatus,
      retryCount: newRetryCount,
      lastError: error,
      lastAttemptAt: DateTime.now(),
    );
  }
  
  // Auto-retry with exponential backoff
  Future<void> scheduleRetry(QueuedMessage queuedMessage) async {
    final retryDelay = Duration(
      seconds: (queuedMessage.retryCount * queuedMessage.retryCount) * 5, // 5s, 20s, 45s
    );
    
    Future.delayed(retryDelay, () async {
      if (_bluetoothService.currentStatus == BluetoothConnectionStatus.connected) {
        await _attemptDelivery(queuedMessage);
      }
    });
  }
}

// Data models for offline messaging

enum MessageQueueStatus {
  pending,
  sending,
  delivered,
  failed,
}

enum DeliveryStatus {
  queued,
  sending,
  delivered,
  failed,
}

class QueuedMessage {
  final ChatMessage message;
  final DateTime queuedAt;
  final int retryCount;
  final MessageQueueStatus status;
  final DateTime? deliveredAt;
  final String? lastError;

  const QueuedMessage({
    required this.message,
    required this.queuedAt,
    required this.retryCount,
    required this.status,
    this.deliveredAt,
    this.lastError,
  });

  QueuedMessage copyWith({
    ChatMessage? message,
    DateTime? queuedAt,
    int? retryCount,
    MessageQueueStatus? status,
    DateTime? deliveredAt,
    String? lastError,
  }) {
    return QueuedMessage(
      message: message ?? this.message,
      queuedAt: queuedAt ?? this.queuedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      lastError: lastError ?? this.lastError,
    );
  }
}

class MessageDeliveryStatus {
  final String messageId;
  final DeliveryStatus status;
  final DateTime? queuedAt;
  final DateTime? deliveredAt;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final String? lastError;

  const MessageDeliveryStatus({
    required this.messageId,
    required this.status,
    this.queuedAt,
    this.deliveredAt,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.lastError,
  });

  MessageDeliveryStatus copyWith({
    String? messageId,
    DeliveryStatus? status,
    DateTime? queuedAt,
    DateTime? deliveredAt,
    DateTime? lastAttemptAt,
    int? retryCount,
    String? lastError,
  }) {
    return MessageDeliveryStatus(
      messageId: messageId ?? this.messageId,
      status: status ?? this.status,
      queuedAt: queuedAt ?? this.queuedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}