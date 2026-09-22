import 'package:joicrememory/l10n/localization.dart';
import '../../../core/ui/loading_skeleton.dart';
import '../../../core/ui/empty_state.dart';
import 'create_event_screen.dart';
import '../domain/usecases/load_nearby_events.dart';
import 'controllers/nearby_events_controller.dart';
import '../../../app/app_scope.dart';
import 'package:flutter/material.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import 'widgets/event_card.dart';
import '../../map/presentation/widgets/map_filters_sheet.dart';
import '../domain/entities/event_filters.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late final NearbyEventsController _controller;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.read(context);
    _controller = NearbyEventsController(
      LoadNearbyEvents(scope.events, scope.location),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _controller.load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.events),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: _openFilters,
                    icon: Icon(Icons.tune),
                    label: Text(
                      _controller.filters.isActive
                          ? context.l10n.filters
                          : context.l10n.filters197,
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildEventList()),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<MapFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (_) => MapFiltersSheet(
            filters: _controller.filters,
            hasLocation: _controller.location.location != null,
          ),
    );
    if (mounted && result?.filters != null) {
      await _controller.applyFilters(result!.filters!);
    }
  }

  Widget _buildEventList() {
    if (_controller.isLoading) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: [LoadingSkeleton()],
      );
    }

    if (_controller.errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline,
        text: context.localizeMessage(_controller.errorMessage!),
        action: _refresh,
      );
    }

    final events = _controller.events;
    if (events.isEmpty) {
      return ListView(
        padding: EdgeInsets.all(24),
        children: [
          EmptyState(
            title: context.l10n.noEventsNearbyYet,
            message:
                !_controller.filters.isActive
                    ? context.l10n.createAnEventAndInvitePeopleToJoin
                    : context.l10n.tryBrowsingAllCategories,
            actionLabel:
                !_controller.filters.isActive
                    ? context.l10n.createEvent
                    : context.l10n.resetFilters,
            onAction: () async {
              if (_controller.filters.isActive) {
                await _controller.applyFilters(EventFilters());
              } else {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (routeContext) => CreateEventScreen(
                          session: widget.session,
                          onCreated: () => Navigator.pop(routeContext),
                        ),
                  ),
                );
                if (mounted) _refresh();
              }
            },
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: events.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
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
                    if (mounted) {
                      _refresh();
                    }
                  });
            },
          );
        },
      ),
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: action,
              icon: Icon(Icons.refresh),
              label: Text(context.l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
