import '../../domain/entities/create_event_input.dart';
import '../../domain/entities/event.dart';
import '../../../../core/network/guard_data.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_api_service.dart';

class ApiEventRepository implements EventRepository {
  const ApiEventRepository(this._remote);
  final EventApiService _remote;

  @override
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
  }) => guardData(
    () => _remote.listEvents(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      category: category,
      categories: categories,
      startsFrom: startsFrom,
      startsBefore: startsBefore,
      search: search,
      limit: limit,
    ),
  );

  @override
  Future<Event> getEvent(String id) => guardData(() => _remote.getEvent(id));

  @override
  Future<List<Event>> listMyEvents() => guardData(() => _remote.listMyEvents());

  @override
  Future<Event> createEvent(CreateEventInput input) =>
      guardData(() => _remote.createEvent(input));

  @override
  Future<Event> updateEvent(String id, CreateEventInput input) =>
      guardData(() => _remote.updateEvent(id, input));
  @override
  Future<Event> setStatus(String id, String status) =>
      guardData(() => _remote.setStatus(id, status));

  @override
  Future<Event> joinEvent(String id) => guardData(() => _remote.joinEvent(id));

  @override
  Future<Event> leaveEvent(String id) =>
      guardData(() => _remote.leaveEvent(id));

  @override
  Future<void> deleteEvent(String id) =>
      guardData(() => _remote.deleteEvent(id));
}
