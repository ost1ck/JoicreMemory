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

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
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
      endsAt: json['endsAt'] == null
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

