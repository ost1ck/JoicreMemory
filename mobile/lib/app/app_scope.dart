import '../core/localization/locale_controller.dart';
import '../features/events/domain/repositories/address_repository.dart';
import 'package:flutter/widgets.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/events/domain/repositories/event_repository.dart';
import '../features/events/domain/repositories/location_repository.dart';
import '../features/chats/domain/repositories/chat_repository.dart';
import '../features/reports/domain/repositories/report_repository.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.theme,
    this.locale,
    required this.events,
    required this.location,
    this.addresses,
    required this.chats,
    required this.reports,
    required super.child,
  });
  final AuthController auth;
  final ThemeController theme;
  final LocaleController? locale;
  final EventRepository events;
  final LocationRepository location;
  final AddressRepository? addresses;
  final ChatRepository chats;
  final ReportRepository reports;

  /// Non-listening lookup is safe in initState. Controllers own notifications.
  static AppScope read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth ||
      theme != oldWidget.theme ||
      locale != oldWidget.locale ||
      events != oldWidget.events ||
      location != oldWidget.location ||
      addresses != oldWidget.addresses ||
      chats != oldWidget.chats ||
      reports != oldWidget.reports;
}
