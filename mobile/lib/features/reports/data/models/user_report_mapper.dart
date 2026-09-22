import '../../domain/entities/user_report.dart';

class UserReportMapper {
  static UserReport fromJson(Map<String, dynamic> json) {
    return UserReport(
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      user: ReportUserMapper.fromJson(json['user'] as Map<String, dynamic>),
      summary: ReportSummaryMapper.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      createdEvents: _eventsFromJson(json['createdEvents']),
      joinedEvents: _eventsFromJson(json['joinedEvents']),
    );
  }
}

class ReportUserMapper {
  static ReportUser fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

class ReportSummaryMapper {
  static ReportSummary fromJson(Map<String, dynamic> json) {
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
                (item) => ReportCategoryBreakdownMapper.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class ReportCategoryBreakdownMapper {
  static ReportCategoryBreakdown fromJson(Map<String, dynamic> json) {
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

class ReportEventMapper {
  static ReportEvent fromJson(Map<String, dynamic> json) {
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
                (item) => ReportParticipantMapper.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class ReportParticipantMapper {
  static ReportParticipant fromJson(Map<String, dynamic> json) {
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
      .map((item) => ReportEventMapper.fromJson(item as Map<String, dynamic>))
      .toList();
}
