class UserReport {
  const UserReport({
    required this.generatedAt,
    required this.user,
    required this.summary,
    required this.createdEvents,
    required this.joinedEvents,
  });

  final DateTime generatedAt;
  final ReportUser user;
  final ReportSummary summary;
  final List<ReportEvent> createdEvents;
  final List<ReportEvent> joinedEvents;

  List<ReportEvent> get allEvents => [...createdEvents, ...joinedEvents];
}

class ReportUser {
  const ReportUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? bio;
}

class ReportSummary {
  const ReportSummary({
    required this.createdEvents,
    required this.joinedEvents,
    required this.totalEvents,
    required this.organizedParticipantTotal,
    required this.totalParticipationHours,
    required this.averageFillRatePercent,
    required this.upcomingEvents,
    required this.completedEvents,
    required this.categories,
  });

  final int createdEvents;
  final int joinedEvents;
  final int totalEvents;
  final int organizedParticipantTotal;
  final double totalParticipationHours;
  final int averageFillRatePercent;
  final int upcomingEvents;
  final int completedEvents;
  final List<ReportCategoryBreakdown> categories;
}

class ReportCategoryBreakdown {
  const ReportCategoryBreakdown({
    required this.category,
    required this.createdCount,
    required this.joinedCount,
    required this.totalCount,
    required this.participantCount,
    required this.durationHours,
  });

  final String category;
  final int createdCount;
  final int joinedCount;
  final int totalCount;
  final int participantCount;
  final double durationHours;
}

class ReportEvent {
  const ReportEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.locationName,
    required this.startsAt,
    required this.participantCount,
    required this.participants,
    this.address,
    this.endsAt,
    this.maxParticipants,
    this.role,
    this.joinedAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String locationName;
  final String? address;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int? maxParticipants;
  final int participantCount;
  final String? role;
  final DateTime? joinedAt;
  final List<ReportParticipant> participants;

  double get durationHours {
    final end = endsAt;
    if (end == null || end.isBefore(startsAt)) {
      return 0;
    }

    final minutes = end.difference(startsAt).inMinutes;
    return minutes <= 0 ? 0 : minutes / 60;
  }

  bool get hasKnownDuration {
    final end = endsAt;
    return end != null && end.isAfter(startsAt);
  }
}

class ReportParticipant {
  const ReportParticipant({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
  });

  final String userId;
  final String fullName;
  final String email;
  final String role;
  final DateTime joinedAt;
  final String? avatarUrl;
}
