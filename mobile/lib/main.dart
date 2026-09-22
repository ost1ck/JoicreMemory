import 'core/localization/chat_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app_dependencies.dart';
import 'app/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final dependencies = await AppDependencies.create();
  runApp(JoicreMemoryApp(dependencies: dependencies));
  unawaited(dependencies.auth.initialize());
}

class JoicreMemoryApp extends StatelessWidget {
  const JoicreMemoryApp({super.key, required this.dependencies});
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    final auth = dependencies.auth;
    final theme = dependencies.theme;
    return AppScope(
      auth: auth,
      theme: theme,
      locale: dependencies.locale,
      events: dependencies.events,
      location: dependencies.location,
      addresses: dependencies.addresses,
      chats: dependencies.chats,
      reports: dependencies.reports,
      child: AnimatedBuilder(
        animation: Listenable.merge([auth, theme, dependencies.locale]),
        builder:
            (context, _) => MaterialApp(
              title: 'JoicreMemory',
              locale:
                  dependencies.locale?.locale ??
                  (dependencies.locale == null ? const Locale('uk') : null),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                ...AppLocalizations.localizationsDelegates,
                const AppChatLocalizationsDelegate(),
              ],
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: theme.mode,
              home:
                  auth.isInitializing
                      ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                      : auth.isAuthenticated
                      ? HomeShell(session: auth)
                      : LoginScreen(session: auth),
            ),
      ),
    );
  }
}
