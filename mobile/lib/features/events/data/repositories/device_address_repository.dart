import 'package:geocoding/geocoding.dart';
import '../../domain/repositories/address_repository.dart';

class DeviceAddressRepository implements AddressRepository {
  DeviceAddressRepository({
    Future<List<Placemark>> Function(double, double)? lookup,
  }) : _lookup = lookup ?? placemarkFromCoordinates;
  final Future<List<Placemark>> Function(double, double) _lookup;
  @override
  Future<EventAddress?> fromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final places = await _lookup(
      latitude,
      longitude,
    ).timeout(const Duration(seconds: 10));
    if (places.isEmpty) return null;
    final place = places.first;
    String join(List<String?> values) => values
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .join(', ');
    final street =
        place.street?.trim().isNotEmpty == true
            ? place.street
            : join([place.thoroughfare, place.subThoroughfare]);
    final address = join([
      street,
      place.locality,
      place.administrativeArea,
      place.country,
    ]);
    if (address.isEmpty) return null;
    final name = join([place.name, place.locality]);
    return EventAddress(
      name: (name.isEmpty ? address : name).substring(
        0,
        (name.isEmpty ? address : name).length.clamp(0, 180),
      ),
      address: address.substring(0, address.length.clamp(0, 240)),
    );
  }
}
