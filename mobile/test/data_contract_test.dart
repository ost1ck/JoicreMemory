import 'package:joicrememory/features/events/data/datasources/event_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joicrememory/core/errors/app_exception.dart';
import 'package:joicrememory/core/network/api_client.dart';
import 'package:joicrememory/features/auth/domain/entities/auth_identity.dart';
import 'package:joicrememory/features/auth/domain/repositories/identity_provider.dart';
import 'package:joicrememory/features/auth/data/datasources/auth_api_service.dart';
import 'package:joicrememory/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:joicrememory/features/events/data/models/event_mapper.dart';
import 'package:joicrememory/features/events/data/models/create_event_mapper.dart';
import 'package:joicrememory/features/events/domain/entities/create_event_input.dart';

class FakeIdentity implements IdentityProvider {
  final identity = const AuthIdentity(
    firebaseUid: 'uid',
    email: 'test@example.com',
    fullName: 'Test',
    isDev: false,
    token: 'initial-token',
  );
  @override
  Future<void> initialize() async {}
  @override
  Future<AuthIdentity?> currentIdentity() async => identity;
  @override
  Future<AuthIdentity> signIn({
    required String email,
    required String password,
  }) async => identity;
  @override
  Future<AuthIdentity> register({
    required String email,
    required String password,
    required String fullName,
  }) async => identity;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost/api'));

  test(
    'discovery forwards search, category, city and limit to the API',
    () async {
      final client = ApiClient();
      Map<String, dynamic>? query;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            query = options.queryParameters;
            handler.resolve(
              Response(requestOptions: options, data: {'data': []}),
            );
          },
        ),
      );
      await EventApiService(client).listEvents(
        latitude: 49.8,
        longitude: 24.0,
        radiusMeters: 20000,
        search: 'толока',
        category: 'cleanup',
        limit: 100,
      );
      expect(query, {
        'latitude': 49.8,
        'longitude': 24.0,
        'radiusMeters': 20000,
        'search': 'толока',
        'category': 'cleanup',
        'limit': 100,
      });
      client.dio.close();
    },
  );

  test('failed profile synchronization clears HTTP credentials', () async {
    final client = ApiClient();
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 500),
              ),
            ),
      ),
    );
    final repository = FirebaseAuthRepository(
      FakeIdentity(),
      AuthApiService(client),
      client,
    );
    await expectLater(
      repository.restoreSession(),
      throwsA(isA<AppException>()),
    );
    expect(client.dio.options.headers.containsKey('Authorization'), isFalse);
    client.dio.close();
  });

  test('authenticated requests obtain a fresh token', () async {
    final client = ApiClient();
    client.setAuth(FakeIdentity().identity);
    var version = 0;
    client.tokenProvider = () async => 'fresh-${++version}';
    final headers = <String>[];
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          headers.add(options.headers['Authorization'] as String);
          handler.resolve(Response(requestOptions: options, data: {}));
        },
      ),
    );
    await client.dio.get('/one');
    await client.dio.get('/two');
    expect(headers, ['Bearer fresh-1', 'Bearer fresh-2']);
    client.dio.close();
  });

  test(
    'event mapper accepts integer coordinates and absent optional fields',
    () {
      final event = EventMapper.fromJson({
        'id': 'event',
        'creatorUserId': 'user',
        'title': 'Title',
        'description': 'Description',
        'category': 'cleanup',
        'status': 'published',
        'locationName': 'Park',
        'latitude': 49,
        'longitude': 24,
        'startsAt': '2026-10-01T10:00:00Z',
      });
      expect(event.latitude, 49.0);
      expect(event.participantCount, 0);
      expect(event.endsAt, isNull);
    },
  );

  test('create payload preserves UTC dates and nullable fields', () {
    final start = DateTime.parse('2026-10-01T13:00:00+03:00');
    final payload = CreateEventMapper.toJson(
      CreateEventInput(
        title: 'Event',
        description: 'Description',
        category: 'cleanup',
        locationName: 'Park',
        latitude: 49,
        longitude: 24,
        startsAt: start,
      ),
    );
    expect(payload['startsAt'], '2026-10-01T10:00:00.000Z');
    expect(payload['endsAt'], isNull);
    expect(payload['maxParticipants'], isNull);
  });
}
