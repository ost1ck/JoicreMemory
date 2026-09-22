class EventLocation {
  const EventLocation(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

enum LocationIssue { disabled, denied, deniedForever, unavailable }

class LocationResult {
  const LocationResult({this.location, this.issue});
  final EventLocation? location;
  final LocationIssue? issue;
}
