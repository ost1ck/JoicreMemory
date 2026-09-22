import '../../domain/entities/event.dart';

class EventMapper {
  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      organizer:
          json['creator'] is Map<String, dynamic>
              ? EventOrganizer(
                id: json['creator']['id'] as String,
                fullName: json['creator']['fullName'] as String,
                avatarUrl: json['creator']['avatarUrl'] as String?,
              )
              : null,
      id: json['id'] as String,
      creatorUserId: json['creatorUserId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      locationName: json['locationName'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt:
          json['endsAt'] == null
              ? null
              : DateTime.parse(json['endsAt'] as String),
      maxParticipants: json['maxParticipants'] as int?,
      imageUrl: json['imageUrl'] as String?,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      chatChannelId: json['chatChannelId'] as String?,
    );
  }
}
