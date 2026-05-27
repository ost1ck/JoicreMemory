import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/session/app_session.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final session = AppSession();
  await session.initialize();

  runApp(JoicreMemoryApp(session: session));
}

class JoicreMemoryApp extends StatelessWidget {
  const JoicreMemoryApp({super.key, required this.session});

  final AppSession session;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        return MaterialApp(
          title: 'JoicreMemory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: session.themeMode,
          home: session.isAuthenticated
              ? HomeShell(session: session)
              : LoginScreen(session: session),
        );
      },
    );
  }
}
