import '../entities/event_filters.dart';
import '../entities/event.dart';
import '../entities/event_location.dart';
import '../repositories/event_repository.dart';
import '../repositories/location_repository.dart';

class NearbyEvents {
  const NearbyEvents(this.events, this.location);
  final List<Event> events;
  final LocationResult location;
}

class LoadNearbyEvents {
  const LoadNearbyEvents(this._events, this._location);
  final EventRepository _events;
  final LocationRepository _location;

  Future<NearbyEvents> call({
    String? category,
    EventFilters filters = const EventFilters(),
  }) async {
    final result = await _location.currentLocation();
    final center = result.location;
    // With no location, show available events instead of searching around an arbitrary point.
    final events = await _events.listEvents(
      latitude: center?.latitude,
      longitude: center?.longitude,
      radiusMeters: filters.radiusMeters,
      categories: filters.categories,
      startsFrom: filters.startsFrom,
      startsBefore: filters.startsBefore,
      category: category,
    );
    return NearbyEvents(
      events.where((event) => event.isDiscoverableAt(DateTime.now())).toList(),
      result,
    );
  }
}
