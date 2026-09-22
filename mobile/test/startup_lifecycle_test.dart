import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:joicrememory/core/network/api_client.dart';
import 'package:joicrememory/features/auth/data/datasources/auth_api_service.dart';
import 'package:joicrememory/features/auth/presentation/controllers/auth_controller.dart';
import 'package:joicrememory/features/chats/data/models/event_chat_mapper.dart';
import 'package:joicrememory/features/events/data/repositories/device_address_repository.dart';
import 'support/fakes.dart';

void main() {
  setUp(() => dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost/api'));
  for (final recover in [true, false]) {
    test('sync timeout retries once; recovery=$recover', () async {
      final client = ApiClient();
      var calls = 0;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            if (calls == 1 || !recover) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.receiveTimeout,
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'data': {
                      'id': 'user',
                      'firebaseUid': 'uid',
                      'email': 'test@example.com',
                      'fullName': 'Test',
                    },
                  },
                ),
              );
            }
          },
        ),
      );
      final result = AuthApiService(
        client,
      ).syncCurrentUser(email: 'test@example.com', fullName: 'Test');
      if (recover) {
        expect((await result).id, 'user');
      } else {
        await expectLater(result, throwsA(isA<DioException>()));
      }
      expect(calls, 2);
      client.dio.close();
    });
  }
  test('unauthorized sync is not retried', () async {
    final client = ApiClient();
    var calls = 0;
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls++;
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 401),
            ),
          );
        },
      ),
    );
    await expectLater(
      AuthApiService(
        client,
      ).syncCurrentUser(email: 'test@example.com', fullName: 'Test'),
      throwsA(isA<DioException>()),
    );
    expect(calls, 1);
    client.dio.close();
  });
  test(
    'restoration retry restores saved identity without password entry',
    () async {
      final repo = FakeAuth()..failure = Exception('offline');
      final auth = AuthController(repo);
      await auth.initialize();
      expect(auth.restorationFailed, isTrue);
      repo
        ..failure = null
        ..restored = testUser;
      await auth.initialize();
      expect(auth.isAuthenticated, isTrue);
      expect(auth.errorMessage, isNull);
      expect(auth.restorationFailed, isFalse);
      expect(repo.signIns, 0);
      auth.dispose();
    },
  );
  test('chat expires exactly at endsAt; completed chats cannot reopen', () {
    final data = {
      'eventId': 'one',
      'eventTitle': 'Event',
      'locationName': 'Park',
      'startsAt': '2026-09-21T10:00:00Z',
      'endsAt': '2026-09-21T12:00:00Z',
      'status': 'published',
      'creatorUserId': 'owner',
      'streamChannelId': 'channel',
    };
    final chat = EventChatMapper.fromJson(data);
    expect(chat.isActiveAt(DateTime.parse('2026-09-21T11:59:59Z')), isTrue);
    expect(chat.isActiveAt(DateTime.parse('2026-09-21T12:00:00Z')), isFalse);
    expect(
      EventChatMapper.fromJson({
        ...data,
        'status': 'completed',
      }).isActiveAt(chat.startsAt),
      isFalse,
    );
  });
  test(
    'reverse geocoding formats an address and tolerates no placemarks',
    () async {
      final repository = DeviceAddressRepository(
        lookup:
            (lat, lng) async => [
              const Placemark(
                name: 'Парк',
                street: 'Паркова, 1',
                locality: 'Львів',
                country: 'Україна',
              ),
            ],
      );
      final address = await repository.fromCoordinates(49, 24);
      expect(address?.name, 'Парк, Львів');
      expect(address?.address, 'Паркова, 1, Львів, Україна');
      expect(
        await DeviceAddressRepository(
          lookup: (_, __) async => [],
        ).fromCoordinates(49, 24),
        isNull,
      );
    },
  );
}
