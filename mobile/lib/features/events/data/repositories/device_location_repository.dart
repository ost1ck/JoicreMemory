import 'package:geolocator/geolocator.dart';
import '../../domain/entities/event_location.dart';
import '../../domain/repositories/location_repository.dart';

class DeviceLocationRepository implements LocationRepository {
  Future<LocationResult>? _pending;

  @override
  Future<LocationResult> currentLocation() {
    // Map and list can mount together; only one permission prompt is needed.
    return _pending ??= _resolve().whenComplete(() => _pending = null);
  }

  Future<LocationResult> _resolve() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(issue: LocationIssue.disabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(issue: LocationIssue.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(issue: LocationIssue.deniedForever);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationResult(
        location: EventLocation(position.latitude, position.longitude),
      );
    } catch (_) {
      return const LocationResult(issue: LocationIssue.unavailable);
    }
  }
}
