import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/bluetooth_messaging_service.dart';
import 'bluetooth_chat_state.dart';

class BluetoothChatCubit extends Cubit<BluetoothChatState> {
  final BluetoothMessagingService _bluetoothService;
  
  final List<ChatMessage> _messages = [];
  final List<String> _typingUsers = [];
  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _devicesSubscription;
  
  BluetoothChatCubit(this._bluetoothService) : super(BluetoothChatInitial());

  Future<void> initializeChat() async {
    emit(BluetoothChatLoading());
    
    try {
      // Initialize Bluetooth service
      const apartmentId = 'current_apartment'; // TODO: Get from context
      const deviceId = 'current_device'; // TODO: Get device ID
      
      final result = await _bluetoothService.initialize(apartmentId, deviceId);
      
      result.fold(
        (failure) => emit(BluetoothChatError('Failed to initialize Bluetooth: ${failure.message}')),
        (_) {
          _setupListeners();
          emit(BluetoothChatLoaded(messages: _messages));
        },
      );
    } catch (e) {
      emit(BluetoothChatError('Failed to initialize chat: ${e.toString()}'));
    }
  }

  Future<void> startDeviceDiscovery() async {
    emit(const BluetoothDeviceDiscovery(availableDevices: [], isScanning: true));
    
    try {
      final result = await _bluetoothService.startDiscovery();
      
      result.fold(
        (failure) => emit(BluetoothChatError('Failed to start discovery: ${failure.message}')),
        (_) {
          // Discovery results will be handled by the devices stream listener
        },
      );
    } catch (e) {
      emit(BluetoothChatError('Failed to start device discovery: ${e.toString()}'));
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    emit(BluetoothChatConnecting());
    
    try {
      final result = await _bluetoothService.connectToDevice(device);
      
      result.fold(
        (failure) => emit(BluetoothChatError('Failed to connect: ${failure.message}')),
        (_) {
          // Connection status will be handled by the status stream listener
        },
      );
    } catch (e) {
      emit(BluetoothChatError('Failed to connect to device: ${e.toString()}'));
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.text,
        content: content,
        senderId: 'current_user', // TODO: Get current user ID
        senderName: 'You', // TODO: Get current user name
        apartmentId: 'current_apartment', // TODO: Get from context
        timestamp: DateTime.now(),
      );
      
      final result = await _bluetoothService.sendMessage(message);
      
      result.fold(
        (failure) => emit(BluetoothChatError('Failed to send message: ${failure.message}')),
        (_) {
          _messages.add(message);
          emit(MessageSent(message));
          emit(BluetoothChatLoaded(messages: List.from(_messages), typingUsers: _typingUsers));
        },
      );
    } catch (e) {
      emit(BluetoothChatError('Failed to send message: ${e.toString()}'));
    }
  }

  void updateTypingStatus(bool isTyping) {
    // TODO: Send typing indicator to other devices
    // For now, just update local state
    print('User typing status: $isTyping');
  }

  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
    emit(BluetoothChatDisconnected());
  }

  void _setupListeners() {
    // Listen for incoming messages
    _messageSubscription = _bluetoothService.messageStream.listen(
      (message) {
        if (message.type == MessageType.text) {
          _messages.add(message);
          emit(MessageReceived(message));
          emit(BluetoothChatLoaded(messages: List.from(_messages), typingUsers: _typingUsers));
        } else if (message.type == MessageType.system) {
          _handleSystemMessage(message);
        }
      },
      onError: (error) {
        emit(BluetoothChatError('Message stream error: ${error.toString()}'));
      },
    );

    // Listen for connection status changes
    _statusSubscription = _bluetoothService.statusStream.listen(
      (status) {
        switch (status) {
          case BluetoothConnectionStatus.connected:
            emit(BluetoothChatConnected(_bluetoothService.connections.map((c) => 
              BluetoothDevice(name: 'Connected Device', address: 'unknown')).toList()));
            break;
          case BluetoothConnectionStatus.connecting:
            emit(BluetoothChatConnecting());
            break;
          case BluetoothConnectionStatus.disconnected:
            emit(BluetoothChatDisconnected());
            break;
          case BluetoothConnectionStatus.scanning:
            // Handle in devices stream
            break;
          case BluetoothConnectionStatus.error:
            emit(const BluetoothChatError('Bluetooth connection error'));
            break;
        }
      },
      onError: (error) {
        emit(BluetoothChatError('Status stream error: ${error.toString()}'));
      },
    );

    // Listen for device discovery updates
    _devicesSubscription = _bluetoothService.devicesStream.listen(
      (devices) {
        final currentState = state;
        if (currentState is BluetoothDeviceDiscovery) {
          emit(BluetoothDeviceDiscovery(
            availableDevices: devices,
            isScanning: currentState.isScanning,
          ));
        } else {
          emit(BluetoothDeviceDiscovery(
            availableDevices: devices,
            isScanning: false,
          ));
        }
      },
      onError: (error) {
        emit(BluetoothChatError('Devices stream error: ${error.toString()}'));
      },
    );
  }

  void _handleSystemMessage(ChatMessage message) {
    // Handle system messages like typing indicators
    try {
      final content = message.content;
      if (content.contains('typing:')) {
        final isTyping = content.contains('typing:true');
        final userId = message.senderId;
        
        if (isTyping && !_typingUsers.contains(userId)) {
          _typingUsers.add(userId);
        } else if (!isTyping) {
          _typingUsers.remove(userId);
        }
        
        emit(TypingStatusChanged(userId: userId, isTyping: isTyping));
        
        // Update the loaded state with new typing users
        final currentState = state;
        if (currentState is BluetoothChatLoaded) {
          emit(currentState.copyWith(typingUsers: List.from(_typingUsers)));
        }
      }
    } catch (e) {
      print('Error handling system message: $e');
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _devicesSubscription?.cancel();
    _bluetoothService.dispose();
    return super.close();
  }
}

// Mock BluetoothDevice class for the UI
class BluetoothDevice {
  final String? name;
  final String address;
  final bool isBonded;

  BluetoothDevice({
    this.name,
    required this.address,
    this.isBonded = false,
  });
}