import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joicrememory/core/errors/app_exception.dart';
import 'package:joicrememory/core/network/guard_data.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/domain/entities/event_location.dart';
import 'package:joicrememory/features/events/domain/entities/create_event_input.dart';
import 'package:joicrememory/features/events/domain/usecases/load_nearby_events.dart';
import 'package:joicrememory/features/events/domain/usecases/create_event.dart';
import 'package:joicrememory/features/events/presentation/controllers/nearby_events_controller.dart';
import 'package:joicrememory/features/events/presentation/controllers/event_details_controller.dart';
import 'support/fakes.dart';

void main() {
  test(
    'domain remains independent of Flutter, SDKs and data implementations',
    () {
      final files = Directory('lib/features')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) => f.path.contains('/domain/') && f.path.endsWith('.dart'),
          );
      expect(files, isNotEmpty);
      for (final file in files) {
        final imports = RegExp(
          r'''(?:import|export) ['"]([^'"]+)''',
        ).allMatches(file.readAsStringSync());
        for (final match in imports) {
          final path = match.group(1)!;
          expect(
            path.contains('package:') ||
                path.contains('/data/') ||
                path.contains('/presentation/'),
            isFalse,
            reason: '${file.path}: $path',
          );
        }
      }
    },
  );

  test('missing location loads events without invented coordinates', () async {
    final events = FakeEvents();
    final result = await LoadNearbyEvents(
      events,
      FakeLocation(const LocationResult(issue: LocationIssue.denied)),
    ).call(category: 'cleanup');
    expect(events.lastLatitude, isNull);
    expect(events.lastLongitude, isNull);
    expect(events.lastCategory, 'cleanup');
    expect(result.events, isNotEmpty);
    expect(result.location.issue, LocationIssue.denied);
  });

  test(
    'latest selected category wins even when earlier request finishes last',
    () async {
      final first = Completer<List<Event>>();
      final second = Completer<List<Event>>();
      final events =
          FakeEvents()
            ..onList =
                (category) =>
                    category == 'cleanup' ? first.future : second.future;
      final controller = NearbyEventsController(
        LoadNearbyEvents(events, FakeLocation()),
      );
      final old = controller.selectCategory('cleanup');
      await Future<void>.delayed(Duration.zero);
      final latest = controller.selectCategory('education');
      await Future<void>.delayed(Duration.zero);
      second.complete([testEvent('latest')]);
      await latest;
      first.complete([testEvent('old')]);
      await old;
      expect(controller.events.single.id, 'latest');
      expect(controller.category, 'education');
      expect(controller.isLoading, isFalse);
      controller.dispose();
    },
  );

  test(
    'request finishing after screen disposal does not notify listeners',
    () async {
      final pending = Completer<List<Event>>();
      final events = FakeEvents()..onList = (_) => pending.future;
      final controller = NearbyEventsController(
        LoadNearbyEvents(events, FakeLocation()),
      );
      final request = controller.load();
      controller.dispose();
      pending.complete([]);
      await request;
    },
  );

  test('event list recovers after a failed request', () async {
    final events =
        FakeEvents()
          ..onList =
              (_) async =>
                  throw const AppException(FailureKind.network, 'Offline');
    final controller = NearbyEventsController(
      LoadNearbyEvents(events, FakeLocation()),
    );
    await controller.load();
    expect(controller.errorMessage, 'Offline');
    expect(controller.isLoading, isFalse);
    events.onList = null;
    await controller.load();
    expect(controller.errorMessage, isNull);
    expect(controller.events, isNotEmpty);
    controller.dispose();
  });

  test(
    'failed restore shows login with a useful error and can recover',
    () async {
      final repository =
          FakeAuth()
            ..failure = const AppException(
              FailureKind.server,
              'Сервіс недоступний',
            );
      final controller = AuthController(repository);
      await controller.initialize();
      expect(controller.isInitializing, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, 'Сервіс недоступний');
      repository.failure = null;
      await controller.signIn(email: 'test@example.com', password: 'password');
      expect(controller.isAuthenticated, isTrue);
      expect(controller.errorMessage, isNull);
      expect(controller.isBusy, isFalse);
      await controller.signOut();
      expect(controller.currentUser, isNull);
      controller.dispose();
    },
  );

  test(
    'successful session restoration restores profile without manual login',
    () async {
      final repository = FakeAuth()..restored = testUser;
      final controller = AuthController(repository);
      await controller.initialize();
      expect(controller.currentUser, testUser);
      expect(repository.signIns, 0);
      controller.dispose();
    },
  );

  test('invalid event dates never reach the server', () async {
    final repository = FakeEvents();
    final input = CreateEventInput(
      title: 'Event',
      description: 'Description',
      category: 'cleanup',
      locationName: 'Park',
      latitude: 49,
      longitude: 24,
      startsAt: DateTime(2026, 10, 1, 12),
      endsAt: DateTime(2026, 10, 1, 11),
    );
    expect(() => CreateEvent(repository)(input), throwsA(isA<AppException>()));
    expect(repository.creates, 0);
  });

  test('participation and changed state survive join and leave', () async {
    final repository = FakeEvents()..items = [];
    final controller = EventDetailsController(repository, testEvent('one'));
    await controller.loadParticipation();
    expect(controller.isJoined, isFalse);
    await controller.join();
    expect(controller.isJoined, isTrue);
    expect(controller.hasChanges, isTrue);
    await controller.leave();
    expect(controller.isJoined, isFalse);
    expect(controller.isBusy, isFalse);
    controller.dispose();
  });

  for (final status in [401, 403, 500]) {
    test(
      'HTTP $status becomes a domain error without leaking server internals',
      () async {
        final request = RequestOptions(path: '/events');
        await expectLater(
          guardData(
            () async =>
                throw DioException(
                  requestOptions: request,
                  response: Response(
                    requestOptions: request,
                    statusCode: status,
                    data: {'message': 'secret database connection'},
                  ),
                ),
          ),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.kind,
                  'kind',
                  status == 401
                      ? FailureKind.unauthorized
                      : status == 403
                      ? FailureKind.forbidden
                      : FailureKind.server,
                )
                .having((e) => e.message, 'message', isNot(contains('secret'))),
          ),
        );
      },
    );
  }
}
