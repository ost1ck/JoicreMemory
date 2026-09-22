import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joicrememory/app/app_scope.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/core/theme/theme_controller.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/home/presentation/home_shell.dart';
import 'package:joicrememory/features/home/presentation/home_screen.dart';
import 'support/fakes.dart';
import 'widget_test.dart' show UnusedChats, UnusedReports, savePreview;

Event sample(
  String id,
  String title,
  DateTime date, {
  String category = 'cleanup',
}) => Event(
  id: id,
  creatorUserId: 'owner',
  title: title,
  description: 'Долучайся до спільноти та змінюй місто разом із нами.',
  category: category,
  status: 'published',
  locationName: 'Стрийський парк, Львів',
  latitude: 49.82,
  longitude: 24.03,
  startsAt: date,
  participantCount: 12,
  maxParticipants: 25,
  distanceMeters: 1200,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font
        in {
          'Roboto': 'assets/fonts/Roboto-Regular.ttf',
          'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets(
      'home opens first, selects city, searches and renders ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final themeController = ThemeController(
          await SharedPreferences.getInstance(),
        );
        final auth = AuthController(FakeAuth()..restored = testUser);
        await auth.initialize();
        final now = DateTime.now();
        final date = now.add(const Duration(hours: 2));
        final events =
            FakeEvents()
              ..items = [
                sample('one', 'Толока у Стрийському парку', date),
                sample(
                  'two',
                  'Зустріч сусідів за кавою',
                  date.add(const Duration(hours: 2)),
                  category: 'community',
                ),
              ];
        final theme = dark ? AppTheme.dark : AppTheme.light;
        final key = GlobalKey();
        await tester.pumpWidget(
          AppScope(
            auth: auth,
            theme: themeController,
            events: events,
            location: FakeLocation(),
            chats: UnusedChats(),
            reports: UnusedReports(),
            child: RepaintBoundary(
              key: key,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme.copyWith(
                  textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
                ),
                home: HomeShell(session: auth),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('ТВОЯ НАСТУПНА ПОДІЯ'), findsOneWidget);
        expect(find.text('Головна'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
        ); // No map or chat SDK starts on the home tab.
        await savePreview(tester, key, 'home-${dark ? 'dark' : 'light'}');
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -540));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await savePreview(tester, key, 'home-feed-${dark ? 'dark' : 'light'}');
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 1200));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('choose-area')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Київ'));
        await tester.pumpAndSettle();
        expect(events.lastLatitude, 50.4501);
        await tester.enterText(find.byKey(const Key('home-search')), 'Толока');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(events.lastSearch, 'Толока');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        auth.dispose();
        themeController.dispose();
      },
    );
  }

  testWidgets('empty home remains usable on a narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final theme = ThemeController(await SharedPreferences.getInstance());
    final auth = AuthController(FakeAuth()..restored = testUser);
    await auth.initialize();
    final events = FakeEvents()..items = [];
    var createTapped = false;
    await tester.pumpWidget(
      AppScope(
        auth: auth,
        theme: theme,
        events: events,
        location: FakeLocation(),
        chats: UnusedChats(),
        reports: UnusedReports(),
        child: MaterialApp(
          theme: AppTheme.light,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.4)),
                child: child!,
              ),
          home: HomeScreen(
            session: auth,
            refreshSignal: 0,
            onCreate: () => createTapped = true,
            onMap: () {},
            onProfile: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Створити подію →'),
      180,
      scrollable:
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
    );
    await tester.tap(find.text('Створити подію →'));
    expect(createTapped, isTrue);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Тут поки тихо. Почнемо з тебе?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
    theme.dispose();
  });
}
