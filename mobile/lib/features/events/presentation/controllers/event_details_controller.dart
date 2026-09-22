import 'package:flutter/foundation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../chats/domain/entities/chat_member.dart';
import '../../../chats/domain/repositories/chat_repository.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class EventDetailsController extends ChangeNotifier {
  EventDetailsController(
    this._repository,
    this.event, {
    ChatRepository? chats,
    this.currentUserId,
  }) : _chats = chats;
  final EventRepository _repository;
  final ChatRepository? _chats;
  final String? currentUserId;
  Event event;
  bool isBusy = false;
  bool isLoadingParticipation = true;
  bool isLoadingDetails = true;
  bool isLoadingMembers = false;
  bool isJoined = false;
  bool hasChanges = false;
  String? participationError;
  String? detailsError;
  String? membersError;
  List<ChatMember> members = const [];
  bool _disposed = false;
  bool get isOrganizer =>
      currentUserId != null && event.creatorUserId == currentUserId;

  Future<void> initialize() async {
    await Future.wait([refreshDetails(), _tryParticipation()]);
    if (!_disposed && (isOrganizer || isJoined)) await loadMembers();
  }

  Future<void> _tryParticipation() async {
    try {
      await loadParticipation();
    } catch (_) {
      /* Exposed through participationError. */
    }
  }

  Future<void> refreshDetails() async {
    isLoadingDetails = true;
    detailsError = null;
    _notify();
    try {
      final updated = await _repository.getEvent(event.id);
      if (!_disposed) event = updated;
    } catch (error) {
      if (!_disposed) detailsError = apiErrorMessage(error);
    } finally {
      if (!_disposed) {
        isLoadingDetails = false;
        _notify();
      }
    }
  }

  Future<void> loadParticipation() async {
    isLoadingParticipation = true;
    participationError = null;
    _notify();
    try {
      final events = await _repository.listMyEvents();
      if (!_disposed) isJoined = events.any((item) => item.id == event.id);
    } catch (error) {
      if (!_disposed) participationError = apiErrorMessage(error);
      rethrow;
    } finally {
      if (!_disposed) {
        isLoadingParticipation = false;
        _notify();
      }
    }
  }

  Future<void> loadMembers() async {
    final chats = _chats;
    if (chats == null ||
        event.status != 'published' ||
        (!isOrganizer && !isJoined)) {
      return;
    }
    isLoadingMembers = true;
    membersError = null;
    _notify();
    try {
      final result = await chats.listMembers(event.id);
      if (!_disposed) members = List.unmodifiable(result);
    } catch (error) {
      if (!_disposed) membersError = apiErrorMessage(error);
    } finally {
      if (!_disposed) {
        isLoadingMembers = false;
        _notify();
      }
    }
  }

  Future<void> join() => _mutate(() async {
    if (!event.isDiscoverableAt(DateTime.now())) {
      throw const AppException(
        FailureKind.validation,
        'Участь у цій події вже недоступна.',
      );
    }
    if (event.maxParticipants != null &&
        event.participantCount >= event.maxParticipants!) {
      throw const AppException(
        FailureKind.validation,
        'Усі місця вже зайняті.',
      );
    }
    event = await _repository.joinEvent(event.id);
    isJoined = true;
    hasChanges = true;
    if (!_disposed) await loadMembers();
  });
  Future<void> leave() => _mutate(() async {
    event = await _repository.leaveEvent(event.id);
    isJoined = false;
    members = const [];
    hasChanges = true;
  });
  Future<void> setStatus(String status) => _mutate(() async {
    event = await _repository.setStatus(event.id, status);
    hasChanges = true;
  });
  Future<void> delete() => _mutate(() async {
    await _repository.deleteEvent(event.id);
    hasChanges = true;
  });
  Future<void> _mutate(Future<void> Function() action) async {
    if (isBusy) return;
    isBusy = true;
    _notify();
    try {
      await action();
    } finally {
      if (!_disposed) {
        isBusy = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
