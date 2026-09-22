import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/presentation/widgets/event_card.dart';
import 'widget_test.dart' show savePreview;

Event cardEvent({
  String? image,
  String status = 'published',
  int count = 12,
  int? max = 25,
  String category = 'cleanup',
}) => Event(
  id: 'preview',
  creatorUserId: 'organizer',
  title: 'Толока у Стрийському парку',
  description: 'Цей довгий опис не повинен з’являтися у картці.',
  category: category,
  status: status,
  locationName: 'Стрийський парк, Львів',
  latitude: 49.8,
  longitude: 24,
  startsAt: DateTime.now().add(const Duration(days: 3)),
  participantCount: count,
  maxParticipants: max,
  imageUrl: image,
  distanceMeters: 1200,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry
        in {
          'Roboto': 'assets/fonts/Roboto-Regular.ttf',
          'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        }.entries) {
      await (FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value))).load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets(
      'card hierarchy and opening details in ${dark ? 'dark' : 'light'} theme',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        var opened = 0;
        final theme = dark ? AppTheme.dark : AppTheme.light;
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme.copyWith(
                textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
              ),
              home: Scaffold(
                appBar: AppBar(title: const Text('Події поруч')),
                body: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    EventCard(event: cardEvent(), onTap: () => opened++),
                    const SizedBox(height: 16),
                    EventCard(
                      event: cardEvent(category: 'education', count: 25),
                      onTap: () => opened++,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('12 учасників'), findsOneWidget);
        expect(find.text('Залишилось місць: 13'), findsOneWidget);
        expect(find.textContaining('Цей довгий опис'), findsNothing);
        expect(find.byKey(const Key('category-cover')), findsWidgets);
        await tester.tap(find.text('Переглянути').first);
        expect(opened, 1);
        expect(tester.takeException(), isNull);
        await savePreview(tester, key, 'cards-${dark ? 'dark' : 'light'}');
      },
    );
  }

  testWidgets(
    'invalid photo URL falls back and full event still opens details',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EventCard(
              event: cardEvent(image: 'not-a-url', count: 25),
              onTap: () => opened = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('category-cover')), findsOneWidget);
      expect(find.text('Усі місця зайняті'), findsOneWidget);
      await tester.tap(find.text('Переглянути'));
      expect(opened, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed remote photo displays fallback without breaking the card', (
    tester,
  ) async {
    // Flutter's test HTTP client returns 400; exercise the actual image error builder.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: EventCard(
            event: cardEvent(image: 'https://example.invalid/cover.jpg'),
            onTap: () {},
          ),
        ),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('category-cover')), findsOneWidget);
    expect(find.text('Переглянути'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled card never advertises remaining places', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EventCard(event: cardEvent(status: 'cancelled'), onTap: () {}),
        ),
      ),
    );
    expect(find.text('Скасовано'), findsOneWidget);
    expect(find.textContaining('Залишилось місць'), findsNothing);
  });

  testWidgets('carousel card supports narrow width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ListView(
                  children: [
                    SizedBox(
                      height: EventCard.featuredHeight(context),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 286,
                            child: EventCard(
                              event: cardEvent(category: 'volunteering'),
                              featured: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Переглянути'), findsOneWidget);
  });

  test('participant labels have correct Ukrainian plural forms', () {
    expect(participantLabel(1), '1 учасник');
    expect(participantLabel(2), '2 учасники');
    expect(participantLabel(12), '12 учасників');
    expect(participantLabel(21), '21 учасник');
    expect(participantLabel(0), '0 учасників');
  });
}
