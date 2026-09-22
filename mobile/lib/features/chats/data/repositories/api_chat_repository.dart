import '../../domain/entities/chat_member.dart';
import '../../domain/entities/event_chat.dart';
import '../../domain/entities/stream_token_data.dart';
import '../../../../core/network/guard_data.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_api_service.dart';

class ApiChatRepository implements ChatRepository {
  const ApiChatRepository(this._remote);
  final ChatApiService _remote;

  @override
  Future<StreamTokenData> getStreamToken() =>
      guardData(() => _remote.getStreamToken());

  @override
  Future<List<EventChat>> listChats() => guardData(() => _remote.listChats());

  @override
  Future<EventChat> updateChatAvatar({
    required String eventId,
    required String? avatarUrl,
  }) => guardData(
    () => _remote.updateChatAvatar(eventId: eventId, avatarUrl: avatarUrl),
  );

  @override
  Future<List<ChatMember>> listMembers(String eventId) =>
      guardData(() => _remote.listMembers(eventId));

  @override
  Future<List<ChatMember>> kickMember({
    required String eventId,
    required String userId,
  }) => guardData(() => _remote.kickMember(eventId: eventId, userId: userId));
}
