import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/session/app_session.dart';
import '../data/event.dart';
import '../data/event_category.dart';
import 'event_category_filter_bar.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  static const _ukraineCenter = LatLng(49.0, 31.0);

  late Future<List<Event>> _eventsFuture;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<Event>> _loadEvents() async {
    final center = await _resolveCurrentLocation();
    return widget.session.eventApi.listEvents(
      latitude: center.latitude,
      longitude: center.longitude,
      radiusMeters: 20000,
      category: _selectedCategory,
    );
  }

  void _refresh() {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Події'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Оновити',
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              EventCategoryFilterBar(
                selectedCategory: _selectedCategory,
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                    _eventsFuture = _loadEvents();
                  });
                },
              ),
              Expanded(child: _buildEventList(snapshot)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(AsyncSnapshot<List<Event>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _MessageState(
        icon: Icons.error_outline,
        text: 'Не вдалося завантажити події',
        action: _refresh,
      );
    }

    final events = snapshot.data ?? [];
    if (events.isEmpty) {
      return _MessageState(
        icon: Icons.event_busy,
        text: 'Поки немає подій поруч',
        action: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          return _EventCard(
            event: event,
            onTap: () {
              Navigator.of(context)
                  .push<bool>(
                    MaterialPageRoute(
                      builder:
                          (_) => EventDetailsScreen(
                            session: widget.session,
                            event: event,
                          ),
                    ),
                  )
                  .then((changed) {
                    if (changed == true && mounted) {
                      _refresh();
                    }
                  });
            },
          );
        },
      ),
    );
  }

  Future<LatLng> _resolveCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _ukraineCenter;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _ukraineCenter;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return _ukraineCenter;
    }
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onTap});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(categoryLabel(event.category)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _Meta(icon: Icons.place_outlined, text: event.locationName),
                  _Meta(
                    icon: Icons.schedule,
                    text: _formatRange(formatter, event),
                  ),
                  if (event.distanceMeters != null)
                    _Meta(
                      icon: Icons.near_me_outlined,
                      text: _formatDistance(event.distanceMeters!),
                    ),
                  _Meta(
                    icon: Icons.group_outlined,
                    text: _participantsText(event),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRange(DateFormat formatter, Event event) {
    final start = formatter.format(event.startsAt.toLocal());
    final end =
        event.endsAt == null ? null : formatter.format(event.endsAt!.toLocal());

    return end == null ? start : '$start - $end';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} м';
    }

    return '${(meters / 1000).toStringAsFixed(1)} км';
  }

  String _participantsText(Event event) {
    final maxParticipants = event.maxParticipants;

    if (maxParticipants == null) {
      return '${event.participantCount}';
    }

    return '${event.participantCount}/$maxParticipants';
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.rosyGranite),
        const SizedBox(width: 4),
        Flexible(child: Text(text)),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.text,
    required this.action,
  });

  final IconData icon;
  final String text;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.rosyGranite),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.refresh),
              label: const Text('Оновити'),
            ),
          ],
        ),
      ),
    );
  }
}
