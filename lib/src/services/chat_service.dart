import '../models/app_models.dart';
import 'api_client.dart';

class ChatService {
  const ChatService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<ChatSummary>> getAllChats({String? token}) async {
    final data = await apiClient.getJson('/chats', token: token);
    return _decodeChatSummaryList(data);
  }

  Future<List<ChatDetail>> getChatsByUser(
    String userId, {
    String? token,
  }) async {
    final data = await apiClient.getJson('/chats/user/$userId', token: token);
    return _decodeChatDetailList(data);
  }

  Future<ChatDetail> getChatById(String chatId, {String? token}) async {
    final data = await apiClient.getJson('/chats/$chatId', token: token);
    return ChatDetail.fromJson(_asMap(data));
  }

  Future<void> markChatAsRead(String chatId, {String? token}) async {
    await apiClient.postJson(
      '/chats/$chatId/read',
      token: token,
      body: const <String, dynamic>{},
    );
  }

  Future<ChatDetail> joinChat(
    String chatId,
    String password, {
    String? token,
  }) async {
    final data = await apiClient.postJson(
      '/chats/$chatId/join',
      token: token,
      body: <String, dynamic>{'password': password},
    );

    return ChatDetail.fromJson(_asMap(data));
  }

  Future<ChatDetail> createChat(
    String name,
    String? password, {
    String? token,
  }) async {
    final body = <String, dynamic>{'name': name};

    if (password != null && password.trim().isNotEmpty) {
      body['password'] = password.trim();
    }

    final data = await apiClient.postJson('/chats', token: token, body: body);

    return ChatDetail.fromJson(_asMap(data));
  }

  Future<ChatDetail> sendMessage(
    String chatId,
    String message, {
    String? token,
  }) async {
    final data = await apiClient.postJson(
      '/chats/$chatId/messages',
      token: token,
      body: <String, dynamic>{'message': message},
    );

    return ChatDetail.fromJson(_asMap(data));
  }

  List<ChatSummary> _decodeChatSummaryList(dynamic data) {
    final list = _asList(data);

    return list
        .whereType<Map>()
        .map((item) => ChatSummary.fromJson(Map<String, dynamic>.from(item)))
        .where((chat) => chat.id.trim().isNotEmpty)
        .toList(growable: false);
  }

  List<ChatDetail> _decodeChatDetailList(dynamic data) {
    final list = _asList(data);

    return list
        .whereType<Map>()
        .map((item) => ChatDetail.fromJson(Map<String, dynamic>.from(item)))
        .where((chat) => chat.id.trim().isNotEmpty)
        .toList(growable: false);
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map && data['chats'] is List) {
      return data['chats'] as List;
    }

    if (data is Map && data['data'] is List) {
      return data['data'] as List;
    }

    if (data is Map && data['items'] is List) {
      return data['items'] as List;
    }

    return const [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw StateError('Invalid chat response.');
  }
}
