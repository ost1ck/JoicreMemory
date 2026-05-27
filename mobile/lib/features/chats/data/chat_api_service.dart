import '../../../core/network/api_client.dart';
import 'chat_member.dart';
import 'event_chat.dart';
import 'stream_token_data.dart';

class ChatApiService {
  const ChatApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<StreamTokenData> getStreamToken() async {
    final response = await _apiClient.dio.get('/chats/stream-token');
    return StreamTokenData.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<EventChat>> listChats() async {
    final response = await _apiClient.dio.get('/chats');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => EventChat.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EventChat> updateChatAvatar({
    required String eventId,
    required String? avatarUrl,
  }) async {
    final response = await _apiClient.dio.patch(
      '/chats/$eventId',
      data: {'avatarUrl': avatarUrl},
    );

    return EventChat.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<ChatMember>> listMembers(String eventId) async {
    final response = await _apiClient.dio.get('/chats/$eventId/members');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => ChatMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMember>> kickMember({
    required String eventId,
    required String userId,
  }) async {
    final response = await _apiClient.dio.delete(
      '/chats/$eventId/members/$userId',
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => ChatMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
