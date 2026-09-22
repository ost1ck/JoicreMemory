import '../entities/chat_member.dart';
import '../entities/event_chat.dart';
import '../entities/stream_token_data.dart';

abstract interface class ChatRepository {
  Future<StreamTokenData> getStreamToken();

  Future<List<EventChat>> listChats();

  Future<EventChat> updateChatAvatar({
    required String eventId,
    required String? avatarUrl,
  });

  Future<List<ChatMember>> listMembers(String eventId);

  Future<List<ChatMember>> kickMember({
    required String eventId,
    required String userId,
  });
}
