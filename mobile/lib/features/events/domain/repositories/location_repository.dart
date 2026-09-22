import '../entities/event_location.dart';

abstract interface class LocationRepository {
  Future<LocationResult> currentLocation();
}
