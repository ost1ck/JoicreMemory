import '../../domain/entities/event_chat.dart';

class EventChatMapper {
  static EventChat fromJson(Map<String, dynamic> json) {
    return EventChat(
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      locationName: json['locationName'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt:
          json['endsAt'] == null
              ? null
              : DateTime.parse(json['endsAt'] as String),
      status: json['status'] as String,
      creatorUserId: json['creatorUserId'] as String,
      streamChannelId: json['streamChannelId'] as String,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      isOrganizer: json['isOrganizer'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
