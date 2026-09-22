import '../core/localization/locale_controller.dart';
import '../features/events/data/repositories/device_address_repository.dart';
import '../features/events/domain/repositories/address_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/data/datasources/auth_service.dart';
import '../features/auth/data/datasources/auth_api_service.dart';
import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/events/data/datasources/event_api_service.dart';
import '../features/events/data/repositories/api_event_repository.dart';
import '../features/events/data/repositories/device_location_repository.dart';
import '../features/events/domain/repositories/event_repository.dart';
import '../features/events/domain/repositories/location_repository.dart';
import '../features/chats/data/datasources/chat_api_service.dart';
import '../features/chats/data/repositories/api_chat_repository.dart';
import '../features/chats/domain/repositories/chat_repository.dart';
import '../features/reports/data/datasources/report_api_service.dart';
import '../features/reports/data/repositories/api_report_repository.dart';
import '../features/reports/domain/repositories/report_repository.dart';

/// Composition root: concrete adapters are constructed here, never in screens.
class AppDependencies {
  AppDependencies({
    required this.auth,
    required this.theme,
    this.locale,
    required this.events,
    required this.location,
    this.addresses,
    required this.chats,
    required this.reports,
  });
  final AuthController auth;
  final ThemeController theme;
  final LocaleController? locale;
  final EventRepository events;
  final LocationRepository location;
  final AddressRepository? addresses;
  final ChatRepository chats;
  final ReportRepository reports;

  static Future<AppDependencies> create() async {
    final client = ApiClient();
    final identity = AuthService();
    client.tokenProvider =
        () async => (await identity.currentIdentity())?.token;
    return AppDependencies(
      auth: AuthController(
        FirebaseAuthRepository(identity, AuthApiService(client), client),
      ),
      theme: ThemeController(await SharedPreferences.getInstance()),
      locale: LocaleController(await SharedPreferences.getInstance()),
      events: ApiEventRepository(EventApiService(client)),
      location: DeviceLocationRepository(),
      addresses: DeviceAddressRepository(),
      chats: ApiChatRepository(ChatApiService(client)),
      reports: ApiReportRepository(ReportApiService(client)),
    );
  }
}
