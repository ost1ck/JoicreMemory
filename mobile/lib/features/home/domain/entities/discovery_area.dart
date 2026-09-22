import '../../../events/domain/entities/event_location.dart';

class DiscoveryArea {
  const DiscoveryArea(this.name, this.center);
  final String name;
  final EventLocation center;
}
