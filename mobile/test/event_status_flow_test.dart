import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joicrememory/app/app_scope.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/core/theme/theme_controller.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/presentation/event_details_screen.dart';
import 'package:joicrememory/features/events/presentation/create_event_screen.dart';
import 'package:joicrememory/features/events/domain/entities/create_event_input.dart';
import 'support/fakes.dart';
import 'event_details_test.dart' show detailEvent, DetailEvents;
import 'widget_test.dart' show UnusedChats, UnusedReports;

class StatusEvents extends DetailEvents {
  final changes = <String>[];
  @override
  Future<Event> setStatus(String id, String status) async {
    changes.add(status);
    items = [detailEvent(owner: 'user', status: status)];
    return items.single;
  }

  @override
  Future<Event> updateEvent(String id, CreateEventInput input) async =>
      setStatus(id, input.status);
}

void main() {
  testWidgets(
    'owner edits draft, publishes after confirmation, and cancels permanently',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final theme = ThemeController(await SharedPreferences.getInstance());
      final auth = AuthController(FakeAuth()..restored = testUser);
      await auth.initialize();
      final event = detailEvent(owner: 'user', status: 'draft');
      final events = StatusEvents()..items = [event];
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
            home: EventDetailsScreen(session: auth, event: event),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> manage() async {
        await tester.tap(find.byKey(const Key('event-primary-action')));
        await tester.pumpAndSettle();
      }

      await manage();
      expect(find.text('Завершити подію'), findsNothing);
      await tester.tap(find.text('Редагувати подію'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateEventScreen), findsOneWidget);
      expect(find.text('Зберегти чернетку'), findsOneWidget);
      await tester.tap(find.text('Зберегти чернетку'));
      await tester.pumpAndSettle();
      expect(events.changes, ['draft']);
      await manage();
      await tester.tap(find.text('Опублікувати'));
      await tester.pumpAndSettle();
      expect(events.changes, ['draft']);
      await tester.tap(find.widgetWithText(FilledButton, 'Опублікувати'));
      await tester.pumpAndSettle();
      expect(events.changes, ['draft', 'published']);
      await manage();
      expect(find.text('Опублікувати'), findsNothing);
      await tester.tap(find.text('Скасувати подію'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Підтвердити'));
      await tester.pumpAndSettle();
      expect(events.changes, ['draft', 'published', 'cancelled']);
      await manage();
      expect(find.text('Редагувати подію'), findsNothing);
      expect(find.text('Опублікувати'), findsNothing);
      expect(find.text('Скасувати подію'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      theme.dispose();
    },
  );
}
