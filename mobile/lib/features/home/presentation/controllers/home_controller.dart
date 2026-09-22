import '../../../events/domain/entities/event_filters.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/domain/entities/event_location.dart';
import '../../../events/domain/repositories/event_repository.dart';
import '../../domain/entities/discovery_area.dart';
import '../../domain/usecases/discover_events.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._discover, this._events, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final DiscoverEvents _discover;
  final EventRepository _events;
  final DateTime Function() _now;
  DiscoveryArea? area;
  EventFilters filters = const EventFilters();
  String? get category =>
      filters.categories.length == 1 ? filters.categories.single : null;
  String query = '';
  List<Event> events = const [];
  Event? nextEvent;
  bool isLoading = true;
  bool isLoadingPersonal = true;
  String? error;
  String? personalError;
  LocationResult location = const LocationResult();
  Timer? _debounce;
  int _generation = 0;
  int _personalGeneration = 0;
  bool _disposed = false;

  bool get hasFilters => query.isNotEmpty || filters.isActive;
  String get areaLabel => area?.name ?? 'Поруч зі мною';
  bool get hasLocation => location.location != null;
  List<Event> get weekend =>
      events.where((event) => isThisWeekend(event, _now())).toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  Future<void> refresh() async {
    _debounce?.cancel();
    await Future.wait([loadFeed(), loadPersonal()]);
  }

  Future<void> selectArea(DiscoveryArea? value) async {
    area = value;
    await _reloadFeed();
  }

  Future<void> selectCategory(String? value) async {
    final categories = filters.categories.toSet();
    if (value == null) {
      categories.clear();
    } else if (!categories.add(value)) {
      categories.remove(value);
    }
    await applyFilters(
      EventFilters(
        categories: List.unmodifiable(categories),
        startsFrom: filters.startsFrom,
        startsBefore: filters.startsBefore,
        radiusMeters: filters.radiusMeters,
      ),
    );
  }

  Future<void> applyFilters(EventFilters value) async {
    filters = value;
    await _reloadFeed();
  }

  Future<void> clearFilters() async {
    query = '';
    filters = const EventFilters();
    await _reloadFeed();
  }

  void search(String value) {
    query = value.trim();
    _debounce?.cancel();
    ++_generation; // Invalidate old responses during the debounce window, too.
    isLoading = true;
    error = null;
    notifyListeners();
    _debounce = Timer(const Duration(milliseconds: 350), loadFeed);
  }

  Future<void> _reloadFeed() async {
    _debounce?.cancel();
    await loadFeed();
  }

  Future<void> loadFeed() async {
    _debounce?.cancel();
    final generation = ++_generation;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _discover(
        area: area,
        filters: filters,
        search: query,
      );
      if (_disposed || generation != _generation) return;
      location = result.location;
      events = List.unmodifiable(
        result.events.where((event) => isDiscoverable(event, _now())),
      );
    } catch (failure) {
      if (_disposed || generation != _generation) return;
      error = apiErrorMessage(failure);
    } finally {
      if (!_disposed && generation == _generation) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadPersonal() async {
    final generation = ++_personalGeneration;
    isLoadingPersonal = true;
    personalError = null;
    notifyListeners();
    try {
      final mine = await _events.listMyEvents();
      if (_disposed || generation != _personalGeneration) return;
      final upcoming =
          mine.where((event) => isDiscoverable(event, _now())).toList()
            ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      nextEvent = upcoming.isEmpty ? null : upcoming.first;
    } catch (failure) {
      if (_disposed || generation != _personalGeneration) return;
      personalError = apiErrorMessage(failure);
    } finally {
      if (!_disposed && generation == _personalGeneration) {
        isLoadingPersonal = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    ++_generation;
    ++_personalGeneration;
    super.dispose();
  }
}
