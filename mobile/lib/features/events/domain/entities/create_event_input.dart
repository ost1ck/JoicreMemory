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
    this.status = 'published',
  });

  final String status;
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
}
