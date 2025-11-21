import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/env.dart'; // nếu bạn có Env.baseUrl, nếu không thì truyền string từ ngoài

class NotificationSocketService {
  NotificationSocketService._internal();
  static final NotificationSocketService I = NotificationSocketService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  /// callback khi có notification mới từ socket
  void Function(Map<String, dynamic>)? onNotification;

  void connect({required int userId, String? baseUrl}) {
    if (_socket != null && _socket!.connected) return;

    final uri = Uri.parse(Env.baseUrl);
    final origin = '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';

    _socket = IO.io(
      origin,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        // gửi userId để server join đúng room
        _socket!.emit('auth', {'userId': userId});
        // ignore: avoid_print
        print('Socket connected, auth userId=$userId');
      })
      ..on('notification:new', (data) {
        // data là object emit từ BE
        // ignore: avoid_print
        print('Socket notification:new $data');
        if (data is Map<String, dynamic> && onNotification != null) {
          onNotification!(data);
        }
      })
      ..onDisconnect((_) {
        // ignore: avoid_print
        print('Socket disconnected');
      });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
