class EventAddress {
  const EventAddress({required this.name, required this.address});
  final String name;
  final String address;
}

abstract interface class AddressRepository {
  Future<EventAddress?> fromCoordinates(double latitude, double longitude);
}
