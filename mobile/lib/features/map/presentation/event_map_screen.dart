import 'package:joicrememory/l10n/localization.dart';
import '../../../core/ui/loading_skeleton.dart';
import '../../../core/ui/empty_state.dart';
import '../../../core/ui/soft_motion.dart';
import '../../events/presentation/create_event_screen.dart';
import '../../events/domain/usecases/load_nearby_events.dart';
import '../../events/presentation/controllers/nearby_events_controller.dart';
import '../../../app/app_scope.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../events/domain/entities/event.dart';
import '../../events/domain/entities/event_filters.dart';
import 'widgets/map_event_card.dart';
import 'widgets/map_filters_sheet.dart';
import '../../events/presentation/event_details_screen.dart';

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key, required this.session});

  final AuthController session;

  @override
  State<EventMapScreen> createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  static const _ukraineCenter = LatLng(49.0, 31.0);

  GoogleMapController? _mapController;
  LatLng _mapCenter = _ukraineCenter;
  LatLng? _userLocation;
  List<Event> _events = [];
  Event? _selectedEvent;
  bool _isLoading = true;
  bool _canShowUserLocation = false;
  bool _showMapNotices = true;
  String? _errorMessage;
  String? _locationNotice;
  EventFilters _filters = EventFilters();
  Timer? _noticeTimer;
  late final NearbyEventsController _controller;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.read(context);
    _controller = NearbyEventsController(
      LoadNearbyEvents(scope.events, scope.location),
    );
    _controller.addListener(_onEventsChanged);
    _loadEvents();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _controller.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() => _controller.applyFilters(_filters);

  void _onEventsChanged() {
    if (!mounted) return;
    final location = _controller.location.location;
    setState(() {
      _isLoading = _controller.isLoading;
      _events =
          _controller.events
              .where(
                (event) =>
                    _filters.categories.isEmpty ||
                    _filters.categories.contains(event.category),
              )
              .toList();
      if (!_controller.isLoading && _controller.errorMessage == null) {
        final selectedId = _selectedEvent?.id;
        _selectedEvent = null;
        for (final event in _events) {
          if (event.id == selectedId) _selectedEvent = event;
        }
      }
      _errorMessage = _controller.errorMessage;
      _locationNotice = _controller.locationNotice;
      _userLocation =
          location == null
              ? null
              : LatLng(location.latitude, location.longitude);
      _mapCenter = _userLocation ?? _ukraineCenter;
      _canShowUserLocation = location != null;
      _showMapNotices = true;
    });
    if (!_isLoading) {
      _scheduleNoticeDismiss();
      if (_selectedEvent == null) _focusMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers =
        _events
            .map(
              (event) => Marker(
                markerId: MarkerId(event.id),
                position: LatLng(event.latitude, event.longitude),
                consumeTapEvents: true,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  _selectedEvent?.id == event.id
                      ? BitmapDescriptor.hueOrange
                      : BitmapDescriptor.hueRed,
                ),
                onTap: () => _selectEvent(event),
              ),
            )
            .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.initiativesMap),
        actions: [
          IconButton(
            onPressed: _loadEvents,
            icon: Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = (250 * MediaQuery.textScalerOf(context).scale(1))
              .clamp(0.0, constraints.maxHeight * .55);
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _mapCenter,
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _focusMap();
                },
                markers: markers,
                padding: EdgeInsets.only(
                  top: 64,
                  bottom:
                      _selectedEvent == null
                          ? bottomInset
                          : cardHeight + bottomInset + 24,
                ),
                onTap: (_) => setState(() => _selectedEvent = null),
                mapToolbarEnabled: false,
                myLocationEnabled: _canShowUserLocation,
                myLocationButtonEnabled: _canShowUserLocation,
                zoomControlsEnabled: false,
              ),
              if (_showMapNotices && _errorMessage != null)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 72,
                  child: _MapNotice(
                    icon: Icons.cloud_off_outlined,
                    text: context.localizeMessage(_errorMessage!),
                  ),
                ),
              if (_showMapNotices &&
                  !_isLoading &&
                  _locationNotice != null &&
                  _errorMessage == null)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 72,
                  child: _MapNotice(
                    icon: Icons.my_location_outlined,
                    text: context.localizeMessage(_locationNotice!),
                  ),
                ),
              if (!_isLoading && _events.isEmpty && _errorMessage == null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 12,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * .5,
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyState(
                          title: context.l10n.noEventsNearbyYet,
                          message:
                              !_filters.isActive
                                  ? context
                                      .l10n
                                      .createAnInitiativeAndInvitePeople
                                  : context
                                      .l10n
                                      .tryAnotherCategoryOrBrowseAllEvents,
                          actionLabel:
                              !_filters.isActive
                                  ? context.l10n.createEvent
                                  : context.l10n.changeFilters,
                          onAction:
                              !_filters.isActive ? _createEvent : _openFilters,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isLoading && _selectedEvent == null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 12,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: LoadingSkeleton(cards: false, count: 1),
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                top: 12,
                child: Row(
                  children: [
                    Flexible(
                      child: FilledButton.tonalIcon(
                        onPressed: _openFilters,
                        icon: Icon(Icons.tune),
                        label: Text(
                          !_filters.isActive
                              ? context.l10n.filters197
                              : context.l10n.filters,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    if (!_isLoading && _errorMessage == null)
                      Chip(
                        label: Text(
                          context.l10n.events284((_events.length).toString()),
                        ),
                      ),
                  ],
                ),
              ),
              if (_selectedEvent != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: bottomInset + 12,
                  height: cardHeight,
                  child: SoftEntrance(
                    key: ValueKey(_selectedEvent!.id),
                    child: MapEventCard(
                      event: _selectedEvent!,
                      onOpen: () => _openDetails(_selectedEvent!),
                      onClose: () => setState(() => _selectedEvent = null),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createEvent() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (routeContext) => CreateEventScreen(
              session: widget.session,
              onCreated: () => Navigator.pop(routeContext),
            ),
      ),
    );
    if (mounted) _loadEvents();
  }

  void _selectEvent(Event event) {
    setState(() => _selectedEvent = event);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(event.latitude, event.longitude)),
      );
    });
  }

  Future<void> _openFilters() async {
    final selection = await showModalBottomSheet<MapFilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (_) => MapFiltersSheet(
            filters: _filters,
            hasLocation: _userLocation != null,
          ),
    );
    if (!mounted || selection?.filters == null) {
      return;
    }
    setState(() {
      _filters = selection!.filters!;
      _selectedEvent = null;
      _events = [];
    });
    await _loadEvents();
  }

  void _scheduleNoticeDismiss() {
    _noticeTimer?.cancel();
    _noticeTimer = Timer(Duration(seconds: 15), () {
      if (!mounted) {
        return;
      }

      setState(() => _showMapNotices = false);
    });
  }

  void _focusMap() {
    final controller = _mapController;

    if (controller == null) {
      return;
    }

    final points = [
      if (_userLocation != null) _userLocation!,
      ..._events.map((event) => LatLng(event.latitude, event.longitude)),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (points.isEmpty) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(_mapCenter, 12));
        return;
      }

      final uniquePoints = _uniquePoints(points);

      if (uniquePoints.length == 1) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(uniquePoints.first, 14),
        );
        return;
      }

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFrom(uniquePoints), 64),
      );
    });
  }

  List<LatLng> _uniquePoints(List<LatLng> points) {
    final unique = <String, LatLng>{};

    for (final point in points) {
      unique['${point.latitude.toStringAsFixed(6)},${point.longitude.toStringAsFixed(6)}'] =
          point;
    }

    return unique.values.toList();
  }

  LatLngBounds _boundsFrom(List<LatLng> points) {
    var southwestLat = points.first.latitude;
    var southwestLng = points.first.longitude;
    var northeastLat = points.first.latitude;
    var northeastLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < southwestLat) {
        southwestLat = point.latitude;
      }
      if (point.longitude < southwestLng) {
        southwestLng = point.longitude;
      }
      if (point.latitude > northeastLat) {
        northeastLat = point.latitude;
      }
      if (point.longitude > northeastLng) {
        northeastLng = point.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  void _openDetails(Event event) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder:
                (_) =>
                    EventDetailsScreen(session: widget.session, event: event),
          ),
        )
        .then((changed) {
          if (mounted) {
            _loadEvents();
          }
        });
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
