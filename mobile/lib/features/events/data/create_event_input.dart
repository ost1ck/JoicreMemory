class CreateEventInput {
  const CreateEventInput({
    required this.title,
    required this.description,
    required this.category,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.startsAt,
    this.address,
    this.endsAt,
    this.maxParticipants,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String category;
  final String locationName;
  final String? address;
  final double latitude;
  final double longitude;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int? maxParticipants;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'locationName': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'startsAt': startsAt.toUtc().toIso8601String(),
      'endsAt': endsAt?.toUtc().toIso8601String(),
      'maxParticipants': maxParticipants,
      'imageUrl': imageUrl,
    };
  }
}

