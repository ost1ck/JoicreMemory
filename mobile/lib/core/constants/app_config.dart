import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  static bool get useDevAuth => dotenv.env['USE_DEV_AUTH'] == 'true';

  static String get streamApiKey => dotenv.env['STREAM_API_KEY'] ?? '';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}

