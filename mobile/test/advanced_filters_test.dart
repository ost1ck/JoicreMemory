import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:joicrememory/core/network/api_client.dart';
import 'package:joicrememory/features/events/data/datasources/event_api_service.dart';
import 'package:joicrememory/features/events/domain/entities/event_filters.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/chats/domain/entities/event_chat.dart';
import 'package:joicrememory/features/chats/domain/usecases/load_active_chats.dart';
import 'package:joicrememory/features/map/presentation/widgets/map_filters_sheet.dart';
import 'support/fakes.dart';
import 'widget_test.dart' show UnusedChats;

class OldChats extends UnusedChats {
  @override
  Future<List<EventChat>> listChats() async => [
    for (final id in ['active', 'expired', 'cancelled', 'missing'])
      EventChat(
        eventId: id,
        eventTitle: id,
        locationName: 'Park',
        startsAt: DateTime.now(),
        status: 'published',
        creatorUserId: 'owner',
        streamChannelId: id,
        participantCount: 1,
        isOrganizer: false,
      ),
  ];
}

Event fixture(String id, DateTime end, {String status = 'published'}) => Event(
  id: id,
  creatorUserId: 'owner',
  title: id,
  description: 'description',
  category: 'cleanup',
  status: status,
  locationName: 'Park',
  latitude: 49,
  longitude: 24,
  startsAt: DateTime.now().subtract(const Duration(hours: 1)),
  endsAt: end,
  participantCount: 1,
);
void main() {
  test(
    'combined filters reach API with UTC date boundaries and radius',
    () async {
      dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost/api');
      final client = ApiClient();
      Map<String, dynamic>? query;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            query = options.queryParameters;
            handler.resolve(
              Response(requestOptions: options, data: {'data': []}),
            );
          },
        ),
      );
      final from = DateTime(2026, 10, 1), before = DateTime(2026, 10, 4);
      await EventApiService(client).listEvents(
        categories: ['cleanup', 'education'],
        startsFrom: from,
        startsBefore: before,
        latitude: 49,
        longitude: 24,
        radiusMeters: 5000,
      );
      expect(query!['categories'], 'cleanup,education');
      expect(query!['category'], isNull);
      expect(query!['startsFrom'], from.toUtc().toIso8601String());
      expect(query!['startsBefore'], before.toUtc().toIso8601String());
      expect(query!['radiusMeters'], 5000);
      client.dio.close();
    },
  );
  test(
    'old chat API without endsAt cannot retain ended or cancelled event chats',
    () async {
      final end = DateTime.now().add(const Duration(hours: 1));
      final events =
          FakeEvents()
            ..items = [
              fixture('active', end),
              fixture(
                'expired',
                DateTime.now().subtract(const Duration(seconds: 1)),
              ),
              fixture('cancelled', end, status: 'cancelled'),
            ];
      final chats = await LoadActiveChats(OldChats(), events)();
      expect(chats.map((c) => c.eventId), ['active']);
      expect(chats.single.endsAt, end);
      expect(chats.single.isActiveAt(end), isFalse);
    },
  );
  for (final hasLocation in [true, false]) {
    testWidgets(
      'advanced filter sheet multiple selection and radius location=$hasLocation',
      (tester) async {
        EventFilters? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder:
                    (context) => TextButton(
                      onPressed: () async {
                        final result =
                            await showModalBottomSheet<MapFilterSelection>(
                              context: context,
                              isScrollControlled: true,
                              builder:
                                  (_) => MapFiltersSheet(
                                    hasLocation: hasLocation,
                                    filters: EventFilters(
                                      categories: const ['cleanup'],
                                      startsFrom: DateTime(2026, 10, 1),
                                      startsBefore: DateTime(2026, 10, 4),
                                      radiusMeters: 5000,
                                    ),
                                  ),
                            );
                        selected = result?.filters;
                      },
                      child: const Text('Open'),
                    ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Освіта'));
        final slider = tester.widget<Slider>(find.byType(Slider));
        expect(slider.value, 5);
        expect(slider.onChanged == null, !hasLocation);
        if (hasLocation) {
          slider.onChanged!(25);
          await tester.pump();
        }
        await tester.ensureVisible(find.text('Показати події'));
        await tester.tap(find.text('Показати події'));
        await tester.pumpAndSettle();
        expect(selected!.categories, containsAll(['cleanup', 'education']));
        expect(selected!.radiusMeters, hasLocation ? 25000 : 5000);
        expect(selected!.startsBefore, DateTime(2026, 10, 4));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
