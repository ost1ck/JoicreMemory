import '../models/create_event_mapper.dart';
import '../models/event_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/create_event_input.dart';
import '../../domain/entities/event.dart';

class EventApiService {
  const EventApiService(this._apiClient);

  final ApiClient _apiClient;

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
  }) async {
    final response = await _apiClient.dio.get(
      '/events',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (latitude != null && longitude != null) 'radiusMeters': radiusMeters,
        if (categories != null && categories.isNotEmpty)
          'categories': categories.join(','),
        if (categories == null || categories.isEmpty)
          if (category != null) 'category': category,
        if (startsFrom != null)
          'startsFrom': startsFrom.toUtc().toIso8601String(),
        if (startsBefore != null)
          'startsBefore': startsBefore.toUtc().toIso8601String(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (limit != null) 'limit': limit,
      },
    );

    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => EventMapper.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Event> getEvent(String id) async {
    final response = await _apiClient.dio.get('/events/$id');
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Event>> listMyEvents() async {
    final response = await _apiClient.dio.get('/events/mine');
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => EventMapper.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Event> createEvent(CreateEventInput input) async {
    final response = await _apiClient.dio.post(
      input.status == 'draft' ? '/events/drafts' : '/events',
      data: CreateEventMapper.toJson(input),
    );
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> updateEvent(String id, CreateEventInput input) async {
    final response = await _apiClient.dio.patch(
      '/events/$id',
      data: CreateEventMapper.toJson(input),
    );
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> setStatus(String id, String status) async {
    final response = await _apiClient.dio.patch(
      '/events/$id',
      data: {'status': status},
    );
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> joinEvent(String id) async {
    final response = await _apiClient.dio.post('/events/$id/join');
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Event> leaveEvent(String id) async {
    final response = await _apiClient.dio.post('/events/$id/leave');
    return EventMapper.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String id) async {
    await _apiClient.dio.delete('/events/$id');
  }
}
