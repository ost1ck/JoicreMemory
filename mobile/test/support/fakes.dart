import 'package:joicrememory/features/auth/domain/entities/app_user.dart';
import 'package:joicrememory/features/auth/domain/repositories/auth_repository.dart';
import 'package:joicrememory/features/events/domain/entities/event.dart';
import 'package:joicrememory/features/events/domain/entities/create_event_input.dart';
import 'package:joicrememory/features/events/domain/entities/event_location.dart';
import 'package:joicrememory/features/events/domain/repositories/event_repository.dart';
import 'package:joicrememory/features/events/domain/repositories/location_repository.dart';

const testUser = AppUser(
  id: 'user',
  firebaseUid: 'firebase-user',
  email: 'test@example.com',
  fullName: 'Тестовий користувач',
);
Event testEvent(String id, {String title = 'Толока у Стрийському парку'}) =>
    Event(
      id: id,
      creatorUserId: 'organizer',
      title: title,
      description: 'Долучайся до спільноти: разом зробимо парк затишнішим.',
      category: 'cleanup',
      status: 'published',
      locationName: 'Стрийський парк, Львів',
      latitude: 49.82,
      longitude: 24.03,
      startsAt: DateTime(2026, 10, 3, 10),
      participantCount: 12,
      maxParticipants: 25,
    );

class FakeEvents implements EventRepository {
  Future<List<Event>> Function(String? category)? onList;
  List<Event> items = [testEvent('one')];
  double? lastLatitude;
  double? lastLongitude;
  String? lastCategory;
  String? lastSearch;
  int creates = 0;
  int joins = 0;
  @override
  Future<List<Event>> listEvents({
    double? latitude,
    double? longitude,
    int radiusMeters = 10000,
    String? category,
    List<String>? categories,
    DateTime? startsFrom,
    DateTime? startsBefore,
    String? search,
    int? limit,
  }) async {
    lastLatitude = latitude;
    lastLongitude = longitude;
    lastCategory =
        category ?? (categories?.length == 1 ? categories!.single : null);
    lastSearch = search;
    return onList == null ? items : await onList!(lastCategory);
  }

  @override
  Future<Event> getEvent(String id) async =>
      items.firstWhere((item) => item.id == id, orElse: () => testEvent(id));

  @override
  Future<List<Event>> listMyEvents() async => items;
  @override
  Future<Event> createEvent(CreateEventInput input) async {
    creates++;
    return testEvent('created');
  }

  @override
  Future<Event> updateEvent(String id, CreateEventInput input) async =>
      testEvent(id);
  @override
  Future<Event> setStatus(String id, String status) async => testEvent(id);
  @override
  Future<Event> joinEvent(String id) async {
    joins++;
    return testEvent(id);
  }

  @override
  Future<Event> leaveEvent(String id) async => testEvent(id);
  @override
  Future<void> deleteEvent(String id) async {}
}

class FakeLocation implements LocationRepository {
  FakeLocation([
    this.result = const LocationResult(location: EventLocation(49.82, 24.03)),
  ]);
  LocationResult result;
  @override
  Future<LocationResult> currentLocation() async => result;
}

class FakeAuth implements AuthRepository {
  Object? failure;
  AppUser? restored;
  int signIns = 0;
  @override
  Future<AppUser?> restoreSession() async {
    if (failure != null) throw failure!;
    return restored;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    signIns++;
    if (failure != null) throw failure!;
    return testUser;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<AppUser> updateProfile({
    required String fullName,
    required String bio,
    required String avatarUrl,
  }) async =>
      testUser.copyWith(fullName: fullName, bio: bio, avatarUrl: avatarUrl);
}
