import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/bluetooth_messaging_service.dart';
import 'cubit/bluetooth_chat_cubit.dart';
import 'cubit/bluetooth_chat_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/typing_indicator.dart';

class BluetoothChatPage extends StatefulWidget {
  const BluetoothChatPage({Key? key}) : super(key: key);

  @override
  State<BluetoothChatPage> createState() => _BluetoothChatPageState();
}

class _BluetoothChatPageState extends State<BluetoothChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    context.read<BluetoothChatCubit>().initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Chat'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<BluetoothChatCubit, BluetoothChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(_getConnectionIcon(state)),
                onPressed: () => _showConnectionDialog(),
                tooltip: _getConnectionTooltip(state),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<BluetoothChatCubit, BluetoothChatState>(
        listener: (context, state) {
          if (state is BluetoothChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MessageSent) {
            _messageController.clear();
            _scrollToBottom();
          } else if (state is MessageReceived) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildConnectionStatus(state),
              Expanded(
                child: _buildMessagesList(state),
              ),
              _buildTypingIndicator(state),
              _buildMessageInput(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(BluetoothChatState state) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (state is BluetoothChatConnected) {
      statusColor = Colors.green;
      statusText = 'Connected to ${state.connectedDevices.length} device(s)';
      statusIcon = Icons.bluetooth_connected;
    } else if (state is BluetoothChatConnecting) {
      statusColor = Colors.orange;
      statusText = 'Connecting...';
      statusIcon = Icons.bluetooth_searching;
    } else if (state is BluetoothChatDisconnected) {
      statusColor = Colors.red;
      statusText = 'Disconnected';
      statusIcon = Icons.bluetooth_disabled;
    } else {
      statusColor = Colors.grey;
      statusText = 'Unknown status';
      statusIcon = Icons.bluetooth;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BluetoothChatState state) {
    if (state is BluetoothChatLoaded) {
      if (state.messages.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          final isMe = message.senderId == 'current_user'; // TODO: Get current user ID
          
          return MessageBubble(
            message: message,
            isMe: isMe,
            showSenderName: !isMe,
          );
        },
      );
    }

    if (state is BluetoothChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your roommates',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BluetoothChatState state) {
    if (state is BluetoothChatLoaded && state.typingUsers.isNotEmpty) {
      return TypingIndicator(typingUsers: state.typingUsers);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageInput(BluetoothChatState state) {
    final isConnected = state is BluetoothChatConnected || state is BluetoothChatLoaded;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: isConnected,
              decoration: InputDecoration(
                hintText: isConnected 
                    ? 'Type a message...' 
                    : 'Connect to start messaging',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _onTypingChanged,
              onSubmitted: isConnected ? (_) => _sendMessage() : null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: isConnected ? _sendMessage : null,
            backgroundColor: isConnected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _onTypingChanged(String text) {
    final isCurrentlyTyping = text.isNotEmpty;
    if (isCurrentlyTyping != _isTyping) {
      _isTyping = isCurrentlyTyping;
      context.read<BluetoothChatCubit>().updateTypingStatus(_isTyping);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<BluetoothChatCubit>().sendMessage(text);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _BluetoothConnectionDialog(),
    );
  }

  IconData _getConnectionIcon(BluetoothChatState state) {
    if (state is BluetoothChatConnected) {
      return Icons.bluetooth_connected;
    } else if (state is BluetoothChatConnecting) {
      return Icons.bluetooth_searching;
    } else {
      return Icons.bluetooth_disabled;
    }
  }

  String _getConnectionTooltip(BluetoothChatState state) {
    if (state is BluetoothChatConnected) {
      return 'Connected';
    } else if (state is BluetoothChatConnecting) {
      return 'Connecting';
    } else {
      return 'Disconnected - Tap to connect';
    }
  }
}

class _BluetoothConnectionDialog extends StatefulWidget {
  @override
  State<_BluetoothConnectionDialog> createState() => _BluetoothConnectionDialogState();
}

class _BluetoothConnectionDialogState extends State<_BluetoothConnectionDialog> {
  @override
  void initState() {
    super.initState();
    context.read<BluetoothChatCubit>().startDeviceDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bluetooth, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Connect to Devices'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: BlocBuilder<BluetoothChatCubit, BluetoothChatState>(
          builder: (context, state) {
            if (state is BluetoothDeviceDiscovery) {
              return Column(
                children: [
                  if (state.isScanning) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Scanning for ZiberLive devices...'),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: state.availableDevices.isEmpty
                        ? _buildNoDevicesFound()
                        : _buildDevicesList(state.availableDevices),
                  ),
                ],
              );
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<BluetoothChatCubit>().startDeviceDiscovery();
          },
          child: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildNoDevicesFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ZiberLive devices found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure other devices have Bluetooth enabled and the ZiberLive app open',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(List<BluetoothDevice> devices) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          leading: Icon(
            Icons.bluetooth,
            color: device.isBonded ? Colors.blue : Colors.grey,
          ),
          title: Text(device.name ?? 'Unknown Device'),
          subtitle: Text(device.address),
          trailing: device.isBonded
              ? Icon(Icons.link, color: Colors.green)
              : null,
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }

  void _connectToDevice(BluetoothDevice device) {
    context.read<BluetoothChatCubit>().connectToDevice(device);
    Navigator.of(context).pop();
  }
}