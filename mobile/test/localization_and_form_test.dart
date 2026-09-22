import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joicrememory/app/app_dependencies.dart';
import 'package:joicrememory/app/app_scope.dart';
import 'package:joicrememory/core/localization/locale_controller.dart';
import 'package:joicrememory/core/localization/chat_localizations.dart';
import 'package:joicrememory/core/theme/theme_controller.dart';
import 'package:joicrememory/core/theme/app_theme.dart';
import 'package:joicrememory/core/errors/app_exception.dart';
import 'package:joicrememory/core/network/api_client.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/events/data/datasources/event_api_service.dart';
import 'package:joicrememory/features/events/data/repositories/api_event_repository.dart';
import 'package:joicrememory/features/events/domain/entities/create_event_input.dart';
import 'package:joicrememory/features/events/presentation/create_event_screen.dart';
import 'package:joicrememory/features/events/presentation/widgets/event_card.dart';
import 'package:joicrememory/l10n/localization.dart';
import 'package:joicrememory/main.dart';
import 'support/fakes.dart';
import 'widget_test.dart' show UnusedChats, UnusedReports;

void main() {
  test('catalogues have identical keys and placeholders', () {
    final uk =
        jsonDecode(File('lib/l10n/app_uk.arb').readAsStringSync()) as Map;
    final en =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map;
    expect(uk.keys.toSet(), en.keys.toSet());
    for (final key in uk.keys.where((key) => !key.startsWith('@'))) {
      expect(en[key], isNotEmpty, reason: key);
      final pattern = RegExp(r'\{arg\d+\}');
      expect(
        pattern.allMatches(en[key]).map((m) => m[0]).toSet(),
        pattern.allMatches(uk[key]).map((m) => m[0]).toSet(),
        reason: key,
      );
    }
    expect(participantLabel(1, locale: 'en'), '1 participant');
    expect(participantLabel(21, locale: 'en'), '21 participants');
    expect(participantLabel(21), '21 учасник');
    expect(
      const UkrainianChatLocalizations().writeAMessageLabel,
      'Напиши повідомлення',
    );
  });

  testWidgets(
    'language selector updates login, preserves input and persists choice',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final locale = LocaleController(prefs);
      final theme = ThemeController(prefs);
      final auth = AuthController(FakeAuth());
      await auth.initialize();
      await tester.pumpWidget(
        JoicreMemoryApp(
          dependencies: AppDependencies(
            auth: auth,
            theme: theme,
            locale: locale,
            events: FakeEvents(),
            location: FakeLocation(),
            chats: UnusedChats(),
            reports: UnusedReports(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.ensureVisible(find.byType(DropdownButton<String>));
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(LocaleController(prefs).languageCode, 'en');
      final fieldContext = tester.element(find.byType(TextFormField).first);
      expect(
        MaterialLocalizations.of(fieldContext).cancelButtonLabel,
        'Cancel',
      );
      await locale.setLanguage('uk');
      await tester.pumpAndSettle();
      expect(find.text('Увійти'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      theme.dispose();
      locale.dispose();
    },
  );

  for (final language in ['uk', 'en']) {
    testWidgets(
      'invalid description is revealed and remains visible after scrolling ($language)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final theme = ThemeController(await SharedPreferences.getInstance());
        final auth = AuthController(FakeAuth());
        final events = FakeEvents();
        final strings = lookupAppLocalizations(Locale(language));
        await tester.pumpWidget(
          AppScope(
            auth: auth,
            theme: theme,
            events: events,
            location: FakeLocation(),
            chats: UnusedChats(),
            reports: UnusedReports(),
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: AppTheme.light,
              home: CreateEventScreen(session: auth, onCreated: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'A good event');
        await tester.enterText(fields.at(1), 'short');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.ensureVisible(fields.last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.publishEvent));
        await tester.pumpAndSettle();
        final error = find.text(strings.atLeastCharacters86);
        expect(error.hitTestable(), findsOneWidget);
        expect(events.creates, 0);
        await tester.ensureVisible(fields.last);
        await tester.pump(const Duration(seconds: 10));
        await tester.ensureVisible(fields.at(1));
        await tester.pumpAndSettle();
        expect(error.hitTestable(), findsOneWidget);
        await tester.enterText(fields.at(1), 'A description long enough');
        await tester.pumpAndSettle();
        expect(error, findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        auth.dispose();
        theme.dispose();
      },
    );
  }

  test('old backend cannot turn draft save into a public event', () async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost/api');
    final client = ApiClient();
    final requests = <String>[];
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request.path);
          expect(request.data['status'], 'draft');
          handler.reject(
            DioException(
              requestOptions: request,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: request, statusCode: 404),
            ),
          );
        },
      ),
    );
    await expectLater(
      ApiEventRepository(EventApiService(client)).createEvent(
        CreateEventInput(
          status: 'draft',
          title: 'Draft event',
          description: 'Description',
          category: 'cleanup',
          locationName: 'Park',
          latitude: 49,
          longitude: 24,
          startsAt: DateTime(2099),
        ),
      ),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'draft_server_unavailable',
        ),
      ),
    );
    expect(requests, ['/events/drafts']);
    client.dio.close();
  });
}
