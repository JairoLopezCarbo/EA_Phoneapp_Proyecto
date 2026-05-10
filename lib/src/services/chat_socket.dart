import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_config.dart';

class ChatSocketService {
  io.Socket? _socket;
  String? _token;

  io.Socket? get socket => _socket;

  io.Socket getOrCreateSocket(String token) {
    if (_socket != null && _token == token) {
      if (!_socket!.connected) {
        _socket!.connect();
      }

      return _socket!;
    }

    disconnect();

    _token = token;

    _socket = io.io(
      ApiConfig.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth(<String, dynamic>{'accessToken': token, 'token': token})
          .setExtraHeaders(<String, dynamic>{'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.connect();

    return _socket!;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _token = null;
  }
}

final ChatSocketService chatSocketService = ChatSocketService();
