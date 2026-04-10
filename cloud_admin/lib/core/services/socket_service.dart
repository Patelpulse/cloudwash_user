import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socketServiceProvider = Provider((ref) => SocketService());

class SocketService {
  IO.Socket? socket;

  void init() {
    // Socket.IO is disabled on admin because Firebase/realtime streams are the
    // source of truth for live content updates.
    socket = null;
  }

  void onNewOrder(Function(dynamic) callback) {
    // Intentionally no-op.
  }

  void dispose() {
    socket?.dispose();
    socket = null;
  }
}
