class EventFilters {
  const EventFilters({
    this.categories = const [],
    this.startsFrom,
    this.startsBefore,
    this.radiusMeters = 20000,
  });
  final List<String> categories;
  final DateTime? startsFrom;

  /// Exclusive upper bound: midnight after the final selected local date.
  final DateTime? startsBefore;
  final int radiusMeters;
  bool get isActive =>
      categories.isNotEmpty ||
      startsFrom != null ||
      startsBefore != null ||
      radiusMeters != 20000;
}
