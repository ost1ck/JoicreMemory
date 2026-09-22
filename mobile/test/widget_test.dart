import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joicrememory/app/app_scope.dart';
import 'package:joicrememory/core/errors/app_exception.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/core/theme/theme_controller.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/auth/presentation/login_screen.dart';
import 'package:joicrememory/features/events/presentation/event_list_screen.dart';
import 'package:joicrememory/features/chats/domain/repositories/chat_repository.dart';
import 'package:joicrememory/features/reports/domain/repositories/report_repository.dart';
import 'support/fakes.dart';

class UnusedChats implements ChatRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnusedReports implements ReportRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Roboto')
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final dark in [false, true]) {
    final label = dark ? 'dark' : 'light';
    test('theme $label has readable text and buttons', () {
      final theme = dark ? AppTheme.dark : AppTheme.light;
      final scheme = theme.colorScheme;
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
      }

      expect(
        contrast(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.surface, scheme.onSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.surface, scheme.onSurfaceVariant),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.primaryContainer, scheme.onPrimaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('login and events render in $label theme', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({'joicrememory_dark_theme': dark});
      final themeController = ThemeController(
        await SharedPreferences.getInstance(),
      );
      final auth = AuthController(FakeAuth());
      await auth.initialize();
      final theme = dark ? AppTheme.dark : AppTheme.light;
      final boundaryKey = GlobalKey();
      Widget wrap(Widget screen) => AppScope(
        auth: auth,
        theme: themeController,
        events: FakeEvents(),
        location: FakeLocation(),
        chats: UnusedChats(),
        reports: UnusedReports(),
        child: RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
            ),
            home: screen,
          ),
        ),
      );
      await tester.pumpWidget(wrap(LoginScreen(session: auth)));
      await tester.pumpAndSettle();
      expect(find.text('Увійти'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await savePreview(tester, boundaryKey, 'login-$label');
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: EventListScreen(session: auth),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 1,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  label: 'Мапа',
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt),
                  label: 'Події',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Створити',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Чати',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Профіль',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Толока у Стрийському парку'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await savePreview(tester, boundaryKey, 'events-$label');
      await tester.tap(find.text('Толока у Стрийському парку'));
      await tester.pumpAndSettle();
      expect(find.text('Деталі події'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      themeController.dispose();
    });
  }

  testWidgets('login shows restoration error and allows retry', (tester) async {
    final repository =
        FakeAuth()
          ..failure = const AppException(
            FailureKind.server,
            'Сервіс тимчасово недоступний',
          );
    final auth = AuthController(repository);
    await auth.initialize();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AnimatedBuilder(
          animation: auth,
          builder: (context, _) => LoginScreen(session: auth),
        ),
      ),
    );
    expect(find.text('Сервіс тимчасово недоступний'), findsOneWidget);
    repository.failure = null;
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();
    expect(auth.isAuthenticated, isTrue);
    expect(find.text('Сервіс тимчасово недоступний'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
  });

  test('theme choice persists across controller recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(preferences);
    await controller.setDark(true);
    final restored = ThemeController(preferences);
    expect(restored.mode, ThemeMode.dark);
    controller.dispose();
    restored.dispose();
  });
}

Future<void> savePreview(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  if (!const bool.fromEnvironment('WRITE_PREVIEWS')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/tmp/joicrememory-$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
