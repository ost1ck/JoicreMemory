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
    this.endsAt,
  });

  final String eventId;
  final String eventTitle;
  final String locationName;
  final DateTime startsAt;
  final DateTime? endsAt;
  bool isActiveAt(DateTime now) =>
      status == 'published' && (endsAt == null || now.isBefore(endsAt!));
  final String status;
  final String creatorUserId;
  final String streamChannelId;
  final int participantCount;
  final bool isOrganizer;
  final String? avatarUrl;
}
