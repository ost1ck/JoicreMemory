import '../entities/create_event_input.dart';
import '../entities/event.dart';

abstract interface class EventRepository {
  Future<List<Event>> listEvents({
    double? latitude,
    double? longitude,
    int radiusMeters = 10000,
    String? category,
    List<String>? categories,
    DateTime? startsFrom,
    DateTime? startsBefore,
    String? search,
    int? limit,
  });

  Future<List<Event>> listMyEvents();

  Future<Event> getEvent(String id);

  Future<Event> createEvent(CreateEventInput input);

  Future<Event> updateEvent(String id, CreateEventInput input);

  Future<Event> setStatus(String id, String status);

  Future<Event> joinEvent(String id);

  Future<Event> leaveEvent(String id);

  Future<void> deleteEvent(String id);
}
