import 'package:cloud_user/core/config/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socketServiceProvider = Provider((ref) => SocketService());

class SocketService {
  IO.Socket? _socket;
  String? _currentUserId;

  void init() {
    if (_socket != null) return;

    String url = AppConfig.baseUrl;
    if (url.endsWith('/api/')) {
      url = url.substring(0, url.length - 5);
    } else if (url.endsWith('/api')) {
      url = url.substring(0, url.length - 4);
    }

    print('🔌 Connecting to Socket: $url');

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // Support fallback
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      print('✅ Socket Connected: ${_socket?.id}');
      if (_currentUserId != null) {
        _socket!.emit('join', _currentUserId);
        print('👤 Re-joined room: $_currentUserId');
      }
    });

    _socket?.onConnectError((data) => print('❌ Socket Connect Error: $data'));
    _socket?.onDisconnect((data) => print('🔌 Socket Disconnected: $data'));
    _socket?.onError((data) => print('⚠️ Socket Error: $data'));
  }

  void joinRoom(String userId) {
    _currentUserId = userId;
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join', userId);
      print('👤 Joined room: $userId');
    }
  }

  void onNotification(Function(Map<String, dynamic>) callback) {
    _socket?.off('notification'); // Prevent duplicate listeners
    _socket?.on('notification', (data) {
      print('📩 Received socket notification: $data');
      if (data is Map) {
        callback(Map<String, dynamic>.from(data));
      }
    });
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
