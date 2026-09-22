import 'package:joicrememory/l10n/localization.dart';
import '../domain/entities/event.dart';
import '../../../core/ui/gradient_panel.dart';
import '../domain/usecases/create_event.dart';
import 'controllers/create_event_controller.dart';
import '../../../app/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/network/api_error_message.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/entities/create_event_input.dart';
import 'event_category.dart';
import 'event_location_picker_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    required this.session,
    required this.onCreated,
    this.initialEvent,
    this.onDraftSaved,
  });

  final AuthController session;
  final VoidCallback onCreated;
  final VoidCallback? onDraftSaved;
  final Event? initialEvent;

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
  DateTime _startsAt = DateTime.now().add(Duration(days: 1));
  DateTime? _endsAt;
  LatLng? _selectedLocation;
  bool _submitted = false;
  bool _isResolvingAddress = false;
  String? _addressNotice;
  int _addressRequest = 0;
  late final CreateEventController _controller;
  bool get _isBusy => _controller.isBusy;
  @override
  void initState() {
    super.initState();
    _endsAt = _startsAt.add(Duration(hours: 2));
    _controller = CreateEventController(
      CreateEvent(AppScope.read(context).events),
    );
    _controller.addListener(_onChanged);
    final event = widget.initialEvent;
    if (event != null) {
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.locationName;
      _addressController.text = event.address ?? '';
      _maxParticipantsController.text = event.maxParticipants?.toString() ?? '';
      _category = event.category;
      _startsAt = event.startsAt.toLocal();
      _endsAt = event.endsAt?.toLocal();
      _selectedLocation = LatLng(event.latitude, event.longitude);
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
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
      firstDate:
          _startsAt.isBefore(DateTime.now()) ? _startsAt : DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: _startsAt,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );

    if (time == null || !mounted) {
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
      if (_endsAt != null && !_endsAt!.isAfter(_startsAt)) {
        _endsAt = _startsAt.add(Duration(hours: 2));
      }
    });
  }

  Future<void> _pickEndDateTime() async {
    final initialEnd = _endsAt ?? _startsAt.add(Duration(hours: 2));
    final date = await showDatePicker(
      context: context,
      firstDate: _startsAt,
      lastDate: _startsAt.add(Duration(days: 365)),
      initialDate: initialEnd.isBefore(_startsAt) ? _startsAt : initialEnd,
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialEnd),
    );

    if (time == null || !mounted) {
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
      _endsAt = selected;
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

      _locationController.clear();
      _addressController.clear();
      _isResolvingAddress = true;
      _addressNotice = null;
    });
    final request = ++_addressRequest;
    try {
      final address = await AppScope.read(
        context,
      ).addresses?.fromCoordinates(result.latitude, result.longitude);
      if (!mounted || request != _addressRequest) return;
      if (address != null) {
        if (_locationController.text.isEmpty) {
          _locationController.text = address.name;
        }
        if (_addressController.text.isEmpty) {
          _addressController.text = address.address;
        }
        _addressNotice =
            context.l10n.addressFoundCheckItAndClarifyTheMeetingPointIf;
      } else {
        _addressNotice = context.l10n.pinSavedNoAddressFoundYouCanAddALandmark;
      }
    } catch (_) {
      if (!mounted || request != _addressRequest) return;
      _addressNotice = context.l10n.pinSavedCouldNotFindTheAddressYouCanEnter;
    } finally {
      if (mounted && request == _addressRequest) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  Future<void> _submit({String? status}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitted = true);
    final invalid = _formKey.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      final ordered =
          invalid.toList()..sort((a, b) {
            final aBox = a.context.findRenderObject() as RenderBox;
            final bBox = b.context.findRenderObject() as RenderBox;
            return aBox
                .localToGlobal(Offset.zero)
                .dy
                .compareTo(bBox.localToGlobal(Offset.zero).dy);
          });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await Scrollable.ensureVisible(
        ordered.first.context,
        alignment: 0.15,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    final selectedLocation = _selectedLocation!;

    try {
      await _controller.submit(
        CreateEventInput(
          status: status ?? widget.initialEvent?.status ?? 'published',
          imageUrl: widget.initialEvent?.imageUrl,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          locationName:
              _locationController.text.trim().isEmpty
                  ? context.l10n.mapPin
                  : _locationController.text.trim(),
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
        eventId: widget.initialEvent?.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (status ?? widget.initialEvent?.status) == 'draft'
                ? context.l10n.draftSavedToYourProfile
                : widget.initialEvent == null
                ? context.l10n.eventPublished
                : context.l10n.changesSaved,
          ),
        ),
      );
      if ((status ?? widget.initialEvent?.status) == 'draft') {
        (widget.onDraftSaved ?? widget.onCreated)();
      } else {
        widget.onCreated();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.couldNotSaveTheEvent(
              (context.localizeMessage(apiErrorMessage(error))).toString(),
            ),
          ),
        ),
      );
    }
  }

  Widget _section(String number, String title, String description) => Padding(
    padding: EdgeInsets.only(top: 28, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number · $title',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEvent == null
              ? context.l10n.newEvent
              : context.l10n.editEvent,
        ),
        actions: [
          if (widget.initialEvent == null ||
              widget.initialEvent?.status == 'draft')
            TextButton.icon(
              label: Text(context.l10n.draft),
              // Saving a draft never publishes it.
              onPressed:
                  _isBusy || _isResolvingAddress
                      ? null
                      : () => _submit(status: 'draft'),
              icon: Icon(Icons.save_outlined),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            onPressed: _isBusy || _isResolvingAddress ? null : _submit,
            icon: Icon(Icons.arrow_forward),
            label: Text(
              _isBusy
                  ? context.l10n.saving
                  : widget.initialEvent == null
                  ? context.l10n.publishEvent
                  : widget.initialEvent?.status == 'draft'
                  ? context.l10n.saveDraft
                  : context.l10n.saveChanges,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isBusy,
          child: Form(
            key: _formKey,
            autovalidateMode:
                _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GradientPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.aGoodCauseStartsWithYou,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        Text(
                          context
                              .l10n
                              .shareYourIdeaChooseAPlaceAndInvitePeopleTo,
                        ),
                      ],
                    ),
                  ),
                  if (widget.initialEvent == null ||
                      widget.initialEvent?.status == 'draft')
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        context.l10n.onlyYouCanSeeThisDraftInYourProfileIt,
                      ),
                    ),
                  _section(
                    '01',
                    context.l10n.aboutTheEvent,
                    context.l10n.whatWillYouDoTogetherAndWhoIsItFor,
                  ),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 140,
                    decoration: InputDecoration(
                      labelText: context.l10n.eventTitle,
                      helperText: context.l10n.characters,
                      hintText: context.l10n.forExampleAParkCleanup,
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().length < 3
                                ? context.l10n.atLeastCharacters
                                : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 7,
                    maxLength: 5000,
                    decoration: InputDecoration(
                      labelText: context.l10n.whatToKnow,
                      helperText: context.l10n.characters84,
                      hintText: context.l10n.thePlanWhatToBringAndWhoCanJoin,
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().length < 10
                                ? context.l10n.atLeastCharacters86
                                : null,
                  ),
                  SizedBox(height: 12),
                  Text(context.l10n.category),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final category in eventCategories)
                        ChoiceChip(
                          label: Text(
                            categoryLabel(
                              category.value,
                              strings: context.l10n,
                            ),
                          ),
                          selected: _category == category.value,
                          onSelected:
                              (_) => setState(() => _category = category.value),
                        ),
                    ],
                  ),
                  _section(
                    '02',
                    context.l10n.whereWeLlMeet,
                    context.l10n.dropAPinWeLlTryToFindTheAddress,
                  ),
                  FormField<LatLng>(
                    validator:
                        (_) =>
                            _selectedLocation == null
                                ? context.l10n.chooseAPlaceOnTheMap
                                : null,
                    builder:
                        (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickLocation,
                              icon: Icon(Icons.map_outlined),
                              label: Text(
                                _selectedLocation == null
                                    ? context.l10n.chooseAPlaceOnTheMap90
                                    : context.l10n.moveTheMapPin,
                              ),
                            ),
                            if (_selectedLocation != null || field.hasError)
                              _SelectedLocationStatus(
                                hasLocation: _selectedLocation != null,
                                errorText: field.errorText,
                              ),
                          ],
                        ),
                  ),
                  if (_isResolvingAddress)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (_addressNotice != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _addressNotice!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    maxLength: 180,
                    validator:
                        (value) =>
                            value != null &&
                                    value.trim().isNotEmpty &&
                                    value.trim().length < 2
                                ? context.l10n.atLeastCharacters92
                                : null,
                    decoration: InputDecoration(
                      labelText: context.l10n.placeNameOrLandmark,
                      hintText: context.l10n.forExampleByTheMainEntrance,
                      helperText:
                          context.l10n.optionalTheMapPinDefinesTheLocation,
                      helperMaxLines: 3,
                      counterText: '',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLength: 240,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: context.l10n.address,
                      hintText: context.l10n.filledInAfterYouChooseAPin,
                      helperText: context.l10n.youCanEditThisOrLeaveItBlank,
                      helperMaxLines: 3,
                      counterText: '',
                    ),
                  ),
                  _section(
                    '03',
                    context.l10n.timeAndParticipants,
                    context.l10n.helpPeoplePlanTheirVisit,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_month_outlined),
                    title: Text(context.l10n.start),
                    subtitle: Text(_formatDateTime(_startsAt)),
                    trailing: Icon(Icons.chevron_right),
                    onTap: _pickStartDateTime,
                  ),
                  Divider(),
                  FormField<DateTime>(
                    validator:
                        (_) =>
                            _endsAt != null && !_endsAt!.isAfter(_startsAt)
                                ? context.l10n.theEndMustBeAfterTheEventStarts
                                : null,
                    builder:
                        (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.schedule),
                              title: Text(context.l10n.end),
                              subtitle: Text(
                                _endsAt == null
                                    ? context.l10n.notSpecified
                                    : _formatDateTime(_endsAt!),
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: _pickEndDateTime,
                            ),
                            if (field.hasError)
                              Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _endsAt == null
                        ? context
                            .l10n
                            .withoutAnEndTimeTheChatCannotBeDeletedAutomatically
                        : context
                            .l10n
                            .theEventChatWillBeDeletedAfterTheEventEnds,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_endsAt != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _endsAt = null),
                        child: Text(context.l10n.leaveTheEndTimeOpen),
                      ),
                    ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.l10n.participantLimit,
                      hintText: context.l10n.forExample,
                      helperText:
                          context.l10n.leaveBlankForUnlimitedParticipation,
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      final number = int.tryParse(value.trim());
                      return number == null || number < 1 || number > 10000
                          ? context.l10n.enterAWholeNumberFromTo
                          : null;
                    },
                  ),
                ],
              ),
            ),
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
        SizedBox(width: 8),
        Expanded(
          child: Text(
            errorText ?? context.l10n.mapLocationSelected,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
