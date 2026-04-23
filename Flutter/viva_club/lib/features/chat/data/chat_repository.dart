import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ChatRepository {
  final Dio _dio = DioClient().dio;
  WebSocketChannel? _channel;

  Stream<dynamic> connect(String roomId, String token) {
    // ws://vivaclubs.site/ws/chat/room_id/?token=...
    final wsUrl = 'wss://vivaclubs.site/ws/chat/$roomId/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    return _channel!.stream.map((event) => jsonDecode(event));
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'message': message}));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }

  Future<List<dynamic>> getChatHistory(String roomId) async {
    try {
      final response = await _dio.get('/chat/messages/', queryParameters: {'room_id': roomId});
      return response.data;
    } catch (e) {
      throw 'Failed to load chat history';
    }
  }
}
