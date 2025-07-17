import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../error/failures.dart';
import '../utils/result.dart';

enum BluetoothConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class BluetoothMessagingService {
  static const String _serviceUuid = '00001101-0000-1000-8000-00805F9B34FB'; // Standard Serial Port Profile UUID
  
  final StreamController<BluetoothConnectionStatus> _statusController = StreamController<BluetoothConnectionStatus>.broadcast();
  final StreamController<List<BluetoothDevice>> _devicesController = StreamController<List<BluetoothDevice>>.broadcast();
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  
  BluetoothConnectionStatus _currentStatus = BluetoothConnectionStatus.disconnected;
  final List<BluetoothDevice> _discoveredDevices = [];
  final Map<String, BluetoothConnection> _connections = {};
  
  String? _apartmentId;
  String? _localDeviceId;

  // Streams
  Stream<BluetoothConnectionStatus> get statusStream => _statusController.stream;
  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;
  Stream<ChatMessage> get messageStream => _messageController.stream;

  // Getters
  BluetoothConnectionStatus get currentStatus => _currentStatus;
  List<BluetoothDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  List<BluetoothConnection> get connections => _connections.values.toList();

  Future<Result<void>> initialize(String apartmentId, String deviceId) async {
    try {
      _apartmentId = apartmentId;
      _localDeviceId = deviceId;
      
      // Check if Bluetooth is available
      final isAvailable = await FlutterBluetoothSerial.instance.isAvailable;
      if (!isAvailable) {
        return const Error(SyncFailure(message: 'Bluetooth is not available on this device'));
      }

      // Request permissions
      final bluetoothPermission = await Permission.bluetooth.request();
      final bluetoothScanPermission = await Permission.bluetoothScan.request();
      final bluetoothConnectPermission = await Permission.bluetoothConnect.request();
      
      if (bluetoothPermission != PermissionStatus.granted ||
          bluetoothScanPermission != PermissionStatus.granted ||
          bluetoothConnectPermission != PermissionStatus.granted) {
        return const Error(PermissionFailure(
          message: 'Bluetooth permissions are required for messaging',
        ));
      }

      // Enable Bluetooth if not enabled
      final isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (!isEnabled) {
        final enableResult = await FlutterBluetoothSerial.instance.requestEnable();
        if (enableResult != true) {
          return const Error(SyncFailure(message: 'Bluetooth must be enabled for messaging'));
        }
      }

      _updateStatus(BluetoothConnectionStatus.disconnected);
      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to initialize Bluetooth service: $e'));
    }
  }

  Future<Result<void>> startDiscovery() async {
    try {
      _updateStatus(BluetoothConnectionStatus.scanning);
      _discoveredDevices.clear();

      // Get bonded devices first
      final bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      for (final device in bondedDevices) {
        if (device.name?.contains('ZiberLive') == true) {
          _discoveredDevices.add(device);
        }
      }

      // Start discovery for new devices
      final discoveryStream = FlutterBluetoothSerial.instance.startDiscovery();
      
      await for (final result in discoveryStream) {
        if (result.device.name?.contains('ZiberLive') == true) {
          final existingIndex = _discoveredDevices.indexWhere(
            (d) => d.address == result.device.address,
          );
          
          if (existingIndex == -1) {
            _discoveredDevices.add(result.device);
          } else {
            _discoveredDevices[existingIndex] = result.device;
          }
          
          _devicesController.add(_discoveredDevices);
        }
      }

      _updateStatus(BluetoothConnectionStatus.disconnected);
      return const Success(null);
    } catch (e) {
      _updateStatus(BluetoothConnectionStatus.error);
      return Error(SyncFailure(message: 'Error during device discovery: $e'));
    }
  }

  Future<Result<void>> connectToDevice(BluetoothDevice device) async {
    try {
      _updateStatus(BluetoothConnectionStatus.connecting);

      final connection = await BluetoothConnection.toAddress(device.address);
      
      _connections[device.address] = connection;
      
      // Listen for incoming messages
      connection.input!.listen(
        (data) => _handleIncomingData(device.address, data),
        onDone: () => _handleDisconnection(device.address),
        onError: (error) => _handleConnectionError(device.address, error),
      );

      _updateStatus(BluetoothConnectionStatus.connected);
      return const Success(null);
    } catch (e) {
      _updateStatus(BluetoothConnectionStatus.error);
      return Error(ConnectionFailure(message: 'Failed to connect to device: $e'));
    }
  }

  Future<Result<void>> sendMessage(ChatMessage message) async {
    try {
      if (_connections.isEmpty) {
        return const Error(ConnectionFailure(message: 'No connected devices'));
      }

      final messageData = jsonEncode(message.toJson());
      final bytes = utf8.encode(messageData + '\n');

      // Send to all connected devices
      for (final connection in _connections.values) {
        connection.output.add(Uint8List.fromList(bytes));
        await connection.output.allSent;
      }

      return const Success(null);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to send message: $e'));
    }
  }

  Future<Result<void>> sendSyncData(Map<String, dynamic> syncData) async {
    try {
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.sync,
        content: jsonEncode(syncData),
        senderId: _localDeviceId ?? 'unknown',
        senderName: 'System',
        apartmentId: _apartmentId ?? '',
        timestamp: DateTime.now(),
      );

      return await sendMessage(message);
    } catch (e) {
      return Error(SyncFailure(message: 'Failed to send sync data: $e'));
    }
  }

  Future<void> disconnect() async {
    try {
      for (final connection in _connections.values) {
        await connection.close();
      }
      _connections.clear();
      _updateStatus(BluetoothConnectionStatus.disconnected);
    } catch (e) {
      print('Error during disconnect: $e');
    }
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _devicesController.close();
    _messageController.close();
  }

  // Private methods
  void _updateStatus(BluetoothConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _handleIncomingData(String deviceAddress, Uint8List data) {
    try {
      final messageString = utf8.decode(data).trim();
      if (messageString.isNotEmpty) {
        final messageData = jsonDecode(messageString) as Map<String, dynamic>;
        final message = ChatMessage.fromJson(messageData);
        
        // Only process messages from the same apartment
        if (message.apartmentId == _apartmentId) {
          _messageController.add(message);
        }
      }
    } catch (e) {
      print('Error processing incoming message: $e');
    }
  }

  void _handleDisconnection(String deviceAddress) {
    _connections.remove(deviceAddress);
    if (_connections.isEmpty) {
      _updateStatus(BluetoothConnectionStatus.disconnected);
    }
  }

  void _handleConnectionError(String deviceAddress, dynamic error) {
    print('Connection error for $deviceAddress: $error');
    _connections.remove(deviceAddress);
    if (_connections.isEmpty) {
      _updateStatus(BluetoothConnectionStatus.error);
    }
  }
}

enum MessageType {
  text,
  sync,
  system,
}

class ChatMessage {
  final String id;
  final MessageType type;
  final String content;
  final String senderId;
  final String senderName;
  final String apartmentId;
  final DateTime timestamp;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.apartmentId,
    required this.timestamp,
    this.replyToId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'apartmentId': apartmentId,
      'timestamp': timestamp.toIso8601String(),
      'replyToId': replyToId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      apartmentId: json['apartmentId'],
      timestamp: DateTime.parse(json['timestamp']),
      replyToId: json['replyToId'],
    );
  }
}