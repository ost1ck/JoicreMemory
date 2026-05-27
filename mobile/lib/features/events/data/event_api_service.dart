import '../../../core/network/api_client.dart';
import 'create_event_input.dart';
import 'event.dart';

class EventApiService {
  const EventApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Event>> listEvents({
    double? latitude,
    double? longitude,
    int radiusMeters = 10000,
    String? category,
  }) async {
    final response = await _apiClient.dio.get(
      '/events',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (latitude != null && longitude != null) 'radiusMeters': radiusMeters,
        if (category != null) 'category': category,
      },
    );

    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Event>> listMyEvents() async {
    final response = await _apiClient.dio.get('/events/mine');
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Event> createEvent(CreateEventInput input) async {
    final response = await _apiClient.dio.post('/events', data: input.toJson());
    return Event.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> joinEvent(String id) async {
    final response = await _apiClient.dio.post('/events/$id/join');
    return Event.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> leaveEvent(String id) async {
    final response = await _apiClient.dio.post('/events/$id/leave');
    return Event.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String id) async {
    await _apiClient.dio.delete('/events/$id');
  }
}
