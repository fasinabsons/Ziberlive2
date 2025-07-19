import 'package:equatable/equatable.dart';
import '../../../../core/services/bluetooth_messaging_service.dart';

abstract class BluetoothChatState extends Equatable {
  const BluetoothChatState();

  @override
  List<Object?> get props => [];
}

class BluetoothChatInitial extends BluetoothChatState {}

class BluetoothChatLoading extends BluetoothChatState {}

class BluetoothChatLoaded extends BluetoothChatState {
  final List<ChatMessage> messages;
  final List<String> typingUsers;

  const BluetoothChatLoaded({
    required this.messages,
    this.typingUsers = const [],
  });

  @override
  List<Object?> get props => [messages, typingUsers];

  BluetoothChatLoaded copyWith({
    List<ChatMessage>? messages,
    List<String>? typingUsers,
  }) {
    return BluetoothChatLoaded(
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}

class BluetoothChatConnecting extends BluetoothChatState {}

class BluetoothChatConnected extends BluetoothChatState {
  final List<BluetoothDevice> connectedDevices;

  const BluetoothChatConnected(this.connectedDevices);

  @override
  List<Object?> get props => [connectedDevices];
}

class BluetoothChatDisconnected extends BluetoothChatState {}

class BluetoothDeviceDiscovery extends BluetoothChatState {
  final List<BluetoothDevice> availableDevices;
  final bool isScanning;

  const BluetoothDeviceDiscovery({
    required this.availableDevices,
    required this.isScanning,
  });

  @override
  List<Object?> get props => [availableDevices, isScanning];
}

class MessageSent extends BluetoothChatState {
  final ChatMessage message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends BluetoothChatState {
  final ChatMessage message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class BluetoothChatError extends BluetoothChatState {
  final String message;

  const BluetoothChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class TypingStatusChanged extends BluetoothChatState {
  final String userId;
  final bool isTyping;

  const TypingStatusChanged({
    required this.userId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, isTyping];
}