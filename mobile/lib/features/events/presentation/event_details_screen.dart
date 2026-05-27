import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/session/app_session.dart';
import '../data/event.dart';
import '../data/event_category.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.session,
    required this.event,
  });

  final AppSession session;
  final Event event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Event _event = widget.event;
  bool _isBusy = false;
  bool _isLoadingParticipation = true;
  bool _isJoined = false;
  bool _hasChanges = false;

  bool get _isCreator => _event.creatorUserId == widget.session.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadParticipationState();
  }

  Future<void> _loadParticipationState() async {
    try {
      final events = await widget.session.eventApi.listMyEvents();

      if (!mounted) {
        return;
      }

      setState(() {
        _isJoined = events.any((event) => event.id == _event.id);
        _isLoadingParticipation = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingParticipation = false);
      }
    }
  }

  Future<void> _join() async {
    setState(() => _isBusy = true);
    try {
      final updated = await widget.session.eventApi.joinEvent(_event.id);
      setState(() {
        _event = updated;
        _isJoined = true;
        _hasChanges = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не вдалося долучитися: ${apiErrorMessage(error)}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _leave() async {
    setState(() => _isBusy = true);
    try {
      final updated = await widget.session.eventApi.leaveEvent(_event.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _event = updated;
        _isJoined = false;
      });
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося вийти: ${apiErrorMessage(error)}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Видалити подію?'),
            content: const Text('Цю дію не можна буде скасувати.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Скасувати'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Видалити'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      await widget.session.eventApi.deleteEvent(_event.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не вдалося видалити подію: ${apiErrorMessage(error)}'),
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
    final formatter = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Деталі події'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_hasChanges),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(categoryLabel(_event.category))),
                  const SizedBox(height: 12),
                  Text(
                    _event.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_event.description),
                  const SizedBox(height: 18),
                  _DetailRow(
                    icon: Icons.place_outlined,
                    text:
                        '${_event.locationName}${_event.address == null ? '' : '\n${_event.address}'}',
                  ),
                  _DetailRow(
                    icon: Icons.schedule,
                    text: _formatRange(formatter, _event),
                  ),
                  _DetailRow(
                    icon: Icons.group_outlined,
                    text: _participantsText(_event),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_isCreator) ...[
            ElevatedButton.icon(
              onPressed: _isBusy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(_isBusy ? 'Зачекай...' : 'Видалити подію'),
            ),
          ] else if (_isJoined) ...[
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _leave,
              icon: const Icon(Icons.logout),
              label: Text(_isBusy ? 'Зачекай...' : 'Вийти з події'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _isBusy || _isLoadingParticipation ? null : _join,
              icon: const Icon(Icons.volunteer_activism),
              label: Text(
                _isBusy || _isLoadingParticipation
                    ? 'Зачекай...'
                    : 'Долучитися',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRange(DateFormat formatter, Event event) {
    final start = formatter.format(event.startsAt.toLocal());
    final end =
        event.endsAt == null ? null : formatter.format(event.endsAt!.toLocal());

    return end == null
        ? 'Початок: $start'
        : 'Початок: $start\nЗавершення: $end';
  }

  String _participantsText(Event event) {
    final maxParticipants = event.maxParticipants;

    if (maxParticipants == null) {
      return '${event.participantCount} учасників';
    }

    return '${event.participantCount}/$maxParticipants учасників';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.rosyGranite),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
