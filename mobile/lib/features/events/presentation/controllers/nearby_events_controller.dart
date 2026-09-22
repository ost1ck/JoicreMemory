import '../../domain/entities/event_filters.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_error_message.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_location.dart';
import '../../domain/usecases/load_nearby_events.dart';

class NearbyEventsController extends ChangeNotifier {
  NearbyEventsController(this._load);
  final LoadNearbyEvents _load;
  List<Event> events = const [];
  LocationResult location = const LocationResult();
  EventFilters filters = const EventFilters();
  String? get category =>
      filters.categories.length == 1 ? filters.categories.single : null;
  String? errorMessage;
  bool isLoading = false;
  int _request = 0;
  bool _disposed = false;

  String? get locationNotice => switch (location.issue) {
    LocationIssue.disabled =>
      'Геолокація вимкнена. Показуємо події без обмеження відстані.',
    LocationIssue.denied => 'Дозволь геолокацію, щоб бачити події поруч.',
    LocationIssue.deniedForever =>
      'Доступ до геолокації можна увімкнути в налаштуваннях пристрою.',
    LocationIssue.unavailable =>
      'Не вдалося визначити позицію. Показуємо доступні події.',
    null => null,
  };

  Future<void> selectCategory(String? value) async {
    await applyFilters(
      EventFilters(
        categories: value == null ? const [] : [value],
        startsFrom: filters.startsFrom,
        startsBefore: filters.startsBefore,
        radiusMeters: filters.radiusMeters,
      ),
    );
  }

  Future<void> applyFilters(EventFilters value) async {
    filters = value;
    events = const [];
    await load();
  }

  Future<void> load() async {
    final request = ++_request;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _load(filters: filters);
      if (_disposed || request != _request) return;
      events = List.unmodifiable(result.events);
      location = result.location;
    } catch (error) {
      if (_disposed || request != _request) return;
      errorMessage = apiErrorMessage(error);
    } finally {
      if (!_disposed && request == _request) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_request;
    super.dispose();
  }
}
