class Event {
  const Event({
    required this.id,
    required this.creatorUserId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.startsAt,
    required this.participantCount,
    this.address,
    this.endsAt,
    this.maxParticipants,
    this.imageUrl,
    this.distanceMeters,
    this.chatChannelId,
    this.organizer,
  });

  final String id;
  final String creatorUserId;
  final String title;
  final String description;
  final String category;
  final String status;
  final String locationName;
  final String? address;
  final double latitude;
  final double longitude;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int? maxParticipants;
  final String? imageUrl;
  final int participantCount;
  final double? distanceMeters;
  final String? chatChannelId;
  final EventOrganizer? organizer;
}

class EventOrganizer {
  const EventOrganizer({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });
  final String id;
  final String fullName;
  final String? avatarUrl;
}

enum EventPhase { draft, upcoming, ongoing, today, ended, cancelled, completed }

extension EventLifecycle on Event {
  EventPhase phaseAt(DateTime now) {
    if (status == 'cancelled') return EventPhase.cancelled;
    if (status == 'completed') return EventPhase.completed;
    if (status != 'published') return EventPhase.draft;
    if (now.isBefore(startsAt)) return EventPhase.upcoming;
    final end = endsAt;
    if (end != null) {
      return now.isBefore(end) ? EventPhase.ongoing : EventPhase.ended;
    }
    // Without an end time, retain the event through its local calendar day.
    // Do not claim it is still ongoing when its duration is unknown.
    final start = startsAt.toLocal();
    final local = now.toLocal();
    return start.year == local.year &&
            start.month == local.month &&
            start.day == local.day
        ? EventPhase.today
        : EventPhase.ended;
  }

  bool isDiscoverableAt(DateTime now) => switch (phaseAt(now)) {
    EventPhase.upcoming || EventPhase.ongoing || EventPhase.today => true,
    _ => false,
  };
}
