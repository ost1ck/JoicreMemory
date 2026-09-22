import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:joicrememory/core/errors/app_exception.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/domain/entities/event_location.dart';
import 'package:joicrememory/features/home/domain/entities/discovery_area.dart';
import 'package:joicrememory/features/home/domain/usecases/discover_events.dart';
import 'package:joicrememory/features/home/presentation/controllers/home_controller.dart';
import 'support/fakes.dart';

Event fixture(
  String id,
  DateTime start, {
  String status = 'published',
  DateTime? end,
}) => Event(
  id: id,
  creatorUserId: 'owner',
  title: id,
  description: 'Event description',
  category: 'community',
  status: status,
  locationName: 'Park',
  latitude: 49,
  longitude: 24,
  startsAt: start,
  endsAt: end,
  participantCount: 3,
);

class HomeEvents extends FakeEvents {
  List<Event> mine = [];
  bool failPersonal = false;
  int requests = 0;
  @override
  Future<List<Event>> listMyEvents() async {
    if (failPersonal) {
      throw const AppException(FailureKind.server, 'Unavailable');
    }
    return mine;
  }

  @override
  Future<List<Event>> listEvents({
    double? latitude,
    double? longitude,
    int radiusMeters = 10000,
    String? category,
    List<String>? categories,
    DateTime? startsFrom,
    DateTime? startsBefore,
    String? search,
    int? limit,
  }) {
    requests++;
    return super.listEvents(
      latitude: latitude,
      longitude: longitude,
      category: category,
      categories: categories,
      startsFrom: startsFrom,
      startsBefore: startsBefore,
      search: search,
      limit: limit,
    );
  }
}

class CountingLocation extends FakeLocation {
  int calls = 0;
  @override
  Future<LocationResult> currentLocation() {
    calls++;
    return super.currentLocation();
  }
}

void main() {
  final now = DateTime(2026, 9, 20, 10); // Sunday
  test(
    'ongoing events remain in discovery and personal feed until end',
    () async {
      final active = fixture(
        'active',
        now.subtract(const Duration(minutes: 12)),
        end: now.add(const Duration(hours: 2)),
      );
      final ended = fixture(
        'ended',
        now.subtract(const Duration(hours: 2)),
        end: now,
      );
      final events =
          HomeEvents()
            ..items = [active, ended]
            ..mine = [active];
      final controller = HomeController(
        DiscoverEvents(events, FakeLocation()),
        events,
        now: () => now,
      );
      await controller.refresh();
      expect(controller.events.map((event) => event.id), ['active']);
      expect(controller.nextEvent?.id, 'active');
      expect(active.phaseAt(active.startsAt), EventPhase.ongoing);
      expect(active.isDiscoverableAt(active.endsAt!), isFalse);
      controller.dispose();
    },
  );

  test('unknown end remains visible only through its local calendar day', () {
    final event = fixture('no-end', DateTime(2026, 9, 20, 9));
    expect(event.phaseAt(now), EventPhase.today);
    expect(event.isDiscoverableAt(DateTime(2026, 9, 21)), isFalse);
  });

  test(
    'weekend includes upcoming Sunday but excludes Monday and past events',
    () {
      expect(
        isThisWeekend(fixture('sunday', DateTime(2026, 9, 20, 12)), now),
        isTrue,
      );
      expect(
        isThisWeekend(fixture('monday', DateTime(2026, 9, 21)), now),
        isFalse,
      );
      expect(
        isThisWeekend(fixture('past', DateTime(2026, 9, 19, 12)), now),
        isFalse,
      );
      expect(
        isThisWeekend(
          fixture('cancelled', DateTime(2026, 9, 20, 12), status: 'cancelled'),
          now,
        ),
        isFalse,
      );
      expect(
        isThisWeekend(
          fixture('next Saturday', DateTime(2026, 9, 26, 12)),
          DateTime(2026, 9, 21),
        ),
        isTrue,
      );
    },
  );

  test(
    'manual city forwards coordinates and search without asking for device location',
    () async {
      final events = HomeEvents();
      final location = CountingLocation();
      await DiscoverEvents(events, location)(
        area: const DiscoveryArea('Львів', EventLocation(49.8397, 24.0297)),
        search: 'толока',
        category: 'cleanup',
      );
      expect(location.calls, 0);
      expect(events.lastLatitude, 49.8397);
      expect(events.lastSearch, 'толока');
      expect(events.lastCategory, 'cleanup');
    },
  );

  test('personal calendar failure does not hide discovery results', () async {
    final events =
        HomeEvents()
          ..failPersonal = true
          ..items = [fixture('future', now.add(const Duration(hours: 1)))];
    final controller = HomeController(
      DiscoverEvents(events, FakeLocation()),
      events,
      now: () => now,
    );
    await controller.refresh();
    expect(controller.personalError, isNotNull);
    expect(controller.error, isNull);
    expect(controller.events.single.id, 'future');
    controller.dispose();
  });

  test(
    'next personal event excludes past, cancelled and completed events and sorts by date',
    () async {
      final events =
          HomeEvents()
            ..mine = [
              fixture('later', now.add(const Duration(days: 2))),
              fixture(
                'cancelled',
                now.add(const Duration(minutes: 5)),
                status: 'cancelled',
              ),
              fixture('past', now.subtract(const Duration(days: 1))),
              fixture('nearest', now.add(const Duration(hours: 1))),
              fixture(
                'completed',
                now.add(const Duration(minutes: 2)),
                status: 'completed',
              ),
            ];
      final controller = HomeController(
        DiscoverEvents(events, FakeLocation()),
        events,
        now: () => now,
      );
      await controller.refresh();
      expect(controller.nextEvent?.id, 'nearest');
      controller.dispose();
    },
  );

  test(
    'old response cannot overwrite the city selected more recently',
    () async {
      final old = Completer<List<Event>>();
      final fresh = Completer<List<Event>>();
      final events = HomeEvents()..onList = (_) => old.future;
      final controller = HomeController(
        DiscoverEvents(events, FakeLocation()),
        events,
        now: () => now,
      );
      final first = controller.loadFeed();
      await Future<void>.delayed(Duration.zero);
      events.onList = (_) => fresh.future;
      final second = controller.selectArea(
        const DiscoveryArea('Київ', EventLocation(50.45, 30.52)),
      );
      fresh.complete([fixture('new', now.add(const Duration(hours: 1)))]);
      await second;
      old.complete([fixture('old', now.add(const Duration(hours: 1)))]);
      await first;
      expect(controller.events.single.id, 'new');
      expect(controller.areaLabel, 'Київ');
      controller.dispose();
    },
  );

  test('search debounces typing and disposal cancels pending work', () async {
    final events = HomeEvents();
    final controller = HomeController(
      DiscoverEvents(events, FakeLocation()),
      events,
      now: () => now,
    );
    controller.search('т');
    controller.search('то');
    controller.search('толока');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(events.requests, 1);
    expect(events.lastSearch, 'толока');
    controller.search('new');
    controller.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(events.requests, 1);
  });
}
