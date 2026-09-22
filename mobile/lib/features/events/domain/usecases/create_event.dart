import '../../../../core/errors/app_exception.dart';
import '../entities/create_event_input.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class CreateEvent {
  const CreateEvent(this._repository);
  final EventRepository _repository;
  Future<Event> call(CreateEventInput input, {String? eventId}) {
    if (input.endsAt != null && !input.endsAt!.isAfter(input.startsAt)) {
      throw const AppException(
        FailureKind.validation,
        'Завершення має бути пізніше за початок події.',
      );
    }
    if (input.maxParticipants != null && input.maxParticipants! < 1) {
      throw const AppException(
        FailureKind.validation,
        'Кількість учасників має бути більшою за нуль.',
      );
    }
    return eventId == null
        ? _repository.createEvent(input)
        : _repository.updateEvent(eventId, input);
  }
}
