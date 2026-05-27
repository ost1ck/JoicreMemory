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

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      user: ReportUser.fromJson(json['user'] as Map<String, dynamic>),
      summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
      createdEvents: _eventsFromJson(json['createdEvents']),
      joinedEvents: _eventsFromJson(json['joinedEvents']),
    );
  }

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

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }
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

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      createdEvents: (json['createdEvents'] as num?)?.toInt() ?? 0,
      joinedEvents: (json['joinedEvents'] as num?)?.toInt() ?? 0,
      totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
      organizedParticipantTotal:
          (json['organizedParticipantTotal'] as num?)?.toInt() ?? 0,
      totalParticipationHours:
          (json['totalParticipationHours'] as num?)?.toDouble() ?? 0,
      averageFillRatePercent:
          (json['averageFillRatePercent'] as num?)?.toInt() ?? 0,
      upcomingEvents: (json['upcomingEvents'] as num?)?.toInt() ?? 0,
      completedEvents: (json['completedEvents'] as num?)?.toInt() ?? 0,
      categories:
          (json['categories'] as List<dynamic>? ?? [])
              .map(
                (item) => ReportCategoryBreakdown.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
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

  factory ReportCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return ReportCategoryBreakdown(
      category: json['category'] as String,
      createdCount: (json['createdCount'] as num?)?.toInt() ?? 0,
      joinedCount: (json['joinedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 0,
    );
  }
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

  factory ReportEvent.fromJson(Map<String, dynamic> json) {
    return ReportEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      locationName: json['locationName'] as String,
      address: json['address'] as String?,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt:
          json['endsAt'] == null
              ? null
              : DateTime.parse(json['endsAt'] as String),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      role: json['role'] as String?,
      joinedAt:
          json['joinedAt'] == null
              ? null
              : DateTime.parse(json['joinedAt'] as String),
      participants:
          (json['participants'] as List<dynamic>? ?? [])
              .map(
                (item) =>
                    ReportParticipant.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

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

  factory ReportParticipant.fromJson(Map<String, dynamic> json) {
    return ReportParticipant(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

List<ReportEvent> _eventsFromJson(Object? value) {
  return (value as List<dynamic>? ?? [])
      .map((item) => ReportEvent.fromJson(item as Map<String, dynamic>))
      .toList();
}
