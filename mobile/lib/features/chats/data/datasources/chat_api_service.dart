import '../models/chat_member_mapper.dart';
import '../models/event_chat_mapper.dart';
import '../models/stream_token_data_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat_member.dart';
import '../../domain/entities/event_chat.dart';
import '../../domain/entities/stream_token_data.dart';

class ChatApiService {
  const ChatApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<StreamTokenData> getStreamToken() async {
    final response = await _apiClient.dio.get('/chats/stream-token');
    return StreamTokenDataMapper.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<EventChat>> listChats() async {
    final response = await _apiClient.dio.get('/chats');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => EventChatMapper.fromJson(item as Map<String, dynamic>))
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

    return EventChatMapper.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<ChatMember>> listMembers(String eventId) async {
    final response = await _apiClient.dio.get('/chats/$eventId/members');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => ChatMemberMapper.fromJson(item as Map<String, dynamic>))
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
        .map((item) => ChatMemberMapper.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
