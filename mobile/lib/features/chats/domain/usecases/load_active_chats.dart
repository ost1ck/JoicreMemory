import '../entities/event_chat.dart';
import '../repositories/chat_repository.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/domain/repositories/event_repository.dart';

/// Events are authoritative, including when an older chat API omits endsAt.
class LoadActiveChats {
  const LoadActiveChats(this.chats, this.events);
  final ChatRepository chats;
  final EventRepository events;
  Future<List<EventChat>> call() async {
    final result = await Future.wait<Object>([
      chats.listChats(),
      events.listMyEvents(),
    ]);
    final byId = {
      for (final event in result[1] as List<Event>) event.id: event,
    };
    final now = DateTime.now();
    return [
      for (final chat in result[0] as List<EventChat>)
        if (byId[chat.eventId] case final event?)
          if (event.isDiscoverableAt(now)) _withEvent(chat, event),
    ];
  }

  EventChat _withEvent(EventChat chat, Event event) {
    final start = event.startsAt.toLocal();
    return EventChat(
      eventId: chat.eventId,
      eventTitle: event.title,
      locationName: event.locationName,
      startsAt: event.startsAt,
      endsAt: event.endsAt ?? DateTime(start.year, start.month, start.day + 1),
      status: event.status,
      creatorUserId: event.creatorUserId,
      streamChannelId: chat.streamChannelId,
      participantCount: event.participantCount,
      isOrganizer: chat.isOrganizer,
      avatarUrl: chat.avatarUrl,
    );
  }
}
