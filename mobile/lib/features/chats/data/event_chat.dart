class EventChat {
  const EventChat({
    required this.eventId,
    required this.eventTitle,
    required this.locationName,
    required this.startsAt,
    required this.status,
    required this.creatorUserId,
    required this.streamChannelId,
    required this.participantCount,
    required this.isOrganizer,
    this.avatarUrl,
  });

  final String eventId;
  final String eventTitle;
  final String locationName;
  final DateTime startsAt;
  final String status;
  final String creatorUserId;
  final String streamChannelId;
  final int participantCount;
  final bool isOrganizer;
  final String? avatarUrl;

  factory EventChat.fromJson(Map<String, dynamic> json) {
    return EventChat(
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      locationName: json['locationName'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      status: json['status'] as String,
      creatorUserId: json['creatorUserId'] as String,
      streamChannelId: json['streamChannelId'] as String,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      isOrganizer: json['isOrganizer'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
