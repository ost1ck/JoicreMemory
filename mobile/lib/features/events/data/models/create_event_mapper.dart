import '../../domain/entities/create_event_input.dart';

class CreateEventMapper {
  static Map<String, dynamic> toJson(CreateEventInput input) => {
    'status': input.status,
    'title': input.title,
    'description': input.description,
    'category': input.category,
    'locationName': input.locationName,
    'address': input.address,
    'latitude': input.latitude,
    'longitude': input.longitude,
    'startsAt': input.startsAt.toUtc().toIso8601String(),
    'endsAt': input.endsAt?.toUtc().toIso8601String(),
    'maxParticipants': input.maxParticipants,
    'imageUrl': input.imageUrl,
  };
}
