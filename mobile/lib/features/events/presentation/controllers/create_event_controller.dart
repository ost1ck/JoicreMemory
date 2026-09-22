import 'package:flutter/foundation.dart';
import '../../domain/entities/create_event_input.dart';
import '../../domain/usecases/create_event.dart';

class CreateEventController extends ChangeNotifier {
  CreateEventController(this._create);
  final CreateEvent _create;
  bool isBusy = false;
  bool _disposed = false;
  Future<void> submit(CreateEventInput input, {String? eventId}) async {
    if (isBusy) return;
    isBusy = true;
    notifyListeners();
    try {
      await _create(input, eventId: eventId);
    } finally {
      if (!_disposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
