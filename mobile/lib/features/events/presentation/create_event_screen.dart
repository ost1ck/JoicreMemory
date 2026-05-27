import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../data/create_event_input.dart';
import '../data/event_category.dart';
import 'event_location_picker_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.session,
    required this.onCreated,
  });

  final AppSession session;
  final VoidCallback onCreated;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  String _category = eventCategories.first.value;
  DateTime _startsAt = DateTime.now().add(const Duration(days: 1));
  DateTime? _endsAt;
  LatLng? _selectedLocation;
  String? _locationSelectionError;
  bool _isBusy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _startsAt,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_endsAt != null && _endsAt!.isBefore(_startsAt)) {
        _endsAt = null;
      }
    });
  }

  Future<void> _pickEndDateTime() async {
    final initialEnd = _endsAt ?? _startsAt.add(const Duration(hours: 2));
    final date = await showDatePicker(
      context: context,
      firstDate: _startsAt,
      lastDate: _startsAt.add(const Duration(days: 365)),
      initialDate: initialEnd.isBefore(_startsAt) ? _startsAt : initialEnd,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialEnd),
    );

    if (time == null) {
      return;
    }

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _endsAt = selected.isBefore(_startsAt) ? _startsAt : selected;
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder:
            (_) =>
                EventLocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _selectedLocation = result;
      _locationSelectionError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedLocation = _selectedLocation;

    if (selectedLocation == null) {
      setState(() {
        _locationSelectionError = 'Обери місце на мапі';
      });
      return;
    }

    setState(() => _isBusy = true);

    try {
      await widget.session.eventApi.createEvent(
        CreateEventInput(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          locationName: _locationController.text.trim(),
          address:
              _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          startsAt: _startsAt,
          endsAt: _endsAt,
          maxParticipants: int.tryParse(_maxParticipantsController.text.trim()),
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Подію створено')));
      widget.onCreated();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не вдалося створити подію: ${apiErrorMessage(error)}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Створити подію')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Назва',
                  hintText: 'Наприклад, прибирання парку',
                  prefixIcon: Icon(Icons.title),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().length < 3
                            ? 'Мінімум 3 символи'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Опис',
                  hintText: 'Коротко опиши, що потрібно зробити',
                  prefixIcon: Icon(Icons.notes),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().length < 10
                            ? 'Мінімум 10 символів'
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Категорія',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items:
                    eventCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.value,
                            child: Text(category.label),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Локація',
                  hintText: 'Наприклад, Стрийський парк',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().length < 2
                            ? 'Вкажи локацію'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адреса',
                  hintText: 'Місто, вулиця або орієнтир',
                  prefixIcon: Icon(Icons.signpost_outlined),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: Icon(
                  _selectedLocation == null
                      ? Icons.add_location_alt_outlined
                      : Icons.edit_location_alt_outlined,
                ),
                label: Text(
                  _selectedLocation == null
                      ? 'Обрати місце на мапі'
                      : 'Змінити місце на мапі',
                ),
              ),
              if (_selectedLocation != null ||
                  _locationSelectionError != null) ...[
                const SizedBox(height: 8),
                _SelectedLocationStatus(
                  hasLocation: _selectedLocation != null,
                  errorText: _locationSelectionError,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Максимум учасників',
                  hintText: 'Наприклад, 30',
                  prefixIcon: Icon(Icons.group_outlined),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickStartDateTime,
                icon: const Icon(Icons.event),
                label: Text('Початок: ${_formatDateTime(_startsAt)}'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickEndDateTime,
                icon: const Icon(Icons.event_available_outlined),
                label: Text(
                  _endsAt == null
                      ? 'Додати завершення'
                      : 'Завершення: ${_formatDateTime(_endsAt!)}',
                ),
              ),
              if (_endsAt != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _endsAt = null),
                    icon: const Icon(Icons.close),
                    label: const Text('Без часу завершення'),
                  ),
                ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _submit,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(_isBusy ? 'Зачекай...' : 'Опублікувати'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.'
        '${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }
}

class _SelectedLocationStatus extends StatelessWidget {
  const _SelectedLocationStatus({required this.hasLocation, this.errorText});

  final bool hasLocation;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isError = errorText != null;
    final color =
        isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            errorText ?? 'Місце на мапі обрано',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
