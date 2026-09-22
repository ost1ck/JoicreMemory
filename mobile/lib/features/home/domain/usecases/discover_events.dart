import '../../../events/domain/entities/event_filters.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/domain/entities/event_location.dart';
import '../../../events/domain/repositories/event_repository.dart';
import '../../../events/domain/repositories/location_repository.dart';
import '../entities/discovery_area.dart';

class DiscoveryResult {
  const DiscoveryResult(this.events, this.location);
  final List<Event> events;
  final LocationResult location;
}

class DiscoverEvents {
  const DiscoverEvents(this._events, this._location);
  final EventRepository _events;
  final LocationRepository _location;

  Future<DiscoveryResult> call({
    DiscoveryArea? area,
    String? category,
    String? search,
    EventFilters filters = const EventFilters(),
  }) async {
    final location =
        area == null
            ? await _location.currentLocation()
            : LocationResult(location: area.center);
    final center = location.location;
    final events = await _events.listEvents(
      latitude: center?.latitude,
      longitude: center?.longitude,
      radiusMeters: filters.radiusMeters,
      categories: filters.categories,
      startsFrom: filters.startsFrom,
      startsBefore: filters.startsBefore,
      category: category,
      search: search,
      limit: 100,
    );
    return DiscoveryResult(events, location);
  }
}

/// All comparisons use the user's local calendar. Sunday belongs to this weekend.
bool isThisWeekend(Event event, DateTime now) {
  final local = now.toLocal();
  final today = DateTime(local.year, local.month, local.day);
  final offset =
      local.weekday == DateTime.sunday ? -1 : DateTime.saturday - local.weekday;
  final saturday = DateTime(today.year, today.month, today.day + offset);
  final monday = DateTime(saturday.year, saturday.month, saturday.day + 2);
  final starts = event.startsAt.toLocal();
  return isDiscoverable(event, now) &&
      !starts.isBefore(saturday) &&
      starts.isBefore(monday);
}

bool isDiscoverable(Event event, DateTime now) => event.isDiscoverableAt(now);
