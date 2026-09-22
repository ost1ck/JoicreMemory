import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joicrememory/app/app_scope.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/core/theme/theme_controller.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/presentation/event_details_screen.dart';
import 'support/fakes.dart';
import 'widget_test.dart' show UnusedChats, UnusedReports, savePreview;

class DetailEvents extends FakeEvents {
  bool membershipFails = false;
  @override
  Future<List<Event>> listMyEvents() async {
    if (membershipFails) throw Exception('offline');
    return [];
  }
}

Event detailEvent({
  String owner = 'organizer',
  int count = 12,
  String status = 'published',
}) => Event(
  id: 'one',
  creatorUserId: owner,
  title: 'Толока у Стрийському парку',
  description:
      'Зберемося біля головного входу, приберемо алеї та познайомимося за чаєм. Рукавички й пакети будуть на місці.',
  category: 'cleanup',
  status: status,
  locationName: 'Стрийський парк, Львів',
  address: 'Головний вхід, вул. Паркова',
  latitude: 49.82,
  longitude: 24.03,
  startsAt: DateTime.now().add(const Duration(days: 2)),
  participantCount: count,
  maxParticipants: 25,
  organizer: EventOrganizer(id: owner, fullName: 'Остап Мельник'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))).load();
    await (FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final scenario in [
    'guest-light',
    'guest-dark',
    'owner',
    'full',
    'cancelled',
    'retry',
  ]) {
    testWidgets('details action and layout: $scenario', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final theme = ThemeController(await SharedPreferences.getInstance());
      final auth = AuthController(FakeAuth()..restored = testUser);
      await auth.initialize();
      final event = detailEvent(
        owner: scenario == 'owner' ? 'user' : 'organizer',
        count: scenario == 'full' ? 25 : 12,
        status: scenario == 'cancelled' ? 'cancelled' : 'published',
      );
      final events =
          DetailEvents()
            ..items = [event]
            ..membershipFails = scenario == 'retry';
      final boundary = GlobalKey();
      await tester.pumpWidget(
        AppScope(
          auth: auth,
          theme: theme,
          events: events,
          location: FakeLocation(),
          chats: UnusedChats(),
          reports: UnusedReports(),
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: (scenario == 'guest-dark' ? AppTheme.dark : AppTheme.light)
                  .copyWith(
                    textTheme: (scenario == 'guest-dark'
                            ? AppTheme.dark
                            : AppTheme.light)
                        .textTheme
                        .apply(fontFamily: 'Roboto'),
                  ),
              home: EventDetailsScreen(session: auth, event: event),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final action = find.byKey(const Key('event-primary-action'));
      final label = switch (scenario) {
        'owner' => 'Керувати подією',
        'full' => 'Усі місця зайняті',
        'cancelled' => 'Подію скасовано',
        'retry' => 'Спробувати ще раз',
        _ => 'Долучитися',
      };
      expect(
        find.descendant(of: action, matching: find.text(label)),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(action).onPressed == null,
        scenario == 'full' || scenario == 'cancelled',
      );
      expect(tester.takeException(), isNull);
      await savePreview(tester, boundary, 'details-$scenario');
      await tester.drag(find.byType(ListView).first, const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(action.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await savePreview(tester, boundary, 'details-$scenario-bottom');
      if (scenario == 'retry') {
        events.membershipFails = false;
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.text('Долучитися'), findsOneWidget);
        expect(events.joins, 0);
      }
      if (scenario.startsWith('guest')) {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(events.joins, 1);
        expect(find.text('Вийти з події'), findsOneWidget);
      }
      if (scenario == 'owner') {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.text('Видалити подію'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      theme.dispose();
    });
  }
}
