import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/session/app_session.dart';
import '../../events/data/event.dart';
import '../../events/presentation/event_category_filter_bar.dart';
import '../../events/presentation/event_details_screen.dart';

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<EventMapScreen> createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  static const _ukraineCenter = LatLng(49.0, 31.0);

  GoogleMapController? _mapController;
  LatLng _mapCenter = _ukraineCenter;
  LatLng? _userLocation;
  List<Event> _events = [];
  bool _isLoading = true;
  bool _canShowUserLocation = false;
  bool _showMapNotices = true;
  String? _errorMessage;
  String? _locationNotice;
  String? _selectedCategory;
  Timer? _noticeTimer;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final locationResult = await _resolveCurrentLocation();
      final searchCenter = locationResult.location;
      final events =
          searchCenter == null
              ? <Event>[]
              : await widget.session.eventApi.listEvents(
                latitude: searchCenter.latitude,
                longitude: searchCenter.longitude,
                radiusMeters: 20000,
                category: _selectedCategory,
              );

      if (mounted) {
        setState(() {
          _mapCenter = searchCenter ?? _ukraineCenter;
          _userLocation = locationResult.location;
          _canShowUserLocation = locationResult.location != null;
          _events = events;
          _errorMessage = null;
          _locationNotice = locationResult.notice;
          _showMapNotices = true;
        });
        _scheduleNoticeDismiss();
        _focusMap();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не вдалося завантажити події на мапі.';
          _showMapNotices = true;
        });
        _scheduleNoticeDismiss();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                infoWindow: InfoWindow(
                  title: event.title,
                  snippet: event.locationName,
                  onTap: () => _openDetails(event),
                ),
              ),
            )
            .toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мапа ініціатив'),
        actions: [
          IconButton(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Оновити',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _mapCenter, zoom: 12),
            onMapCreated: (controller) {
              _mapController = controller;
              _focusMap();
            },
            markers: markers,
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
                text: _errorMessage!,
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
                text: _locationNotice!,
              ),
            ),
          if (_showMapNotices &&
              !_isLoading &&
              _events.isEmpty &&
              _errorMessage == null)
            Positioned(
              left: 16,
              right: 16,
              top: _locationNotice == null ? 72 : 144,
              child: const _MapNotice(
                icon: Icons.place_outlined,
                text: 'Поки немає подій поруч.',
              ),
            ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: 12,
            child: EventCategoryFilterBar(
              selectedCategory: _selectedCategory,
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _loadEvents();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleNoticeDismiss() {
    _noticeTimer?.cancel();
    _noticeTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) {
        return;
      }

      setState(() => _showMapNotices = false);
    });
  }

  Future<_LocationResult> _resolveCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return const _LocationResult(
          notice:
              'Геолокація вимкнена. Увімкни Location у симуляторі або на пристрої.',
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const _LocationResult(
          notice: 'Дозволь геолокацію, щоб бачити події поруч із собою.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const _LocationResult(
          notice: 'Доступ до геолокації заборонений у налаштуваннях пристрою.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return _LocationResult(
        location: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const _LocationResult(
        notice:
            'Не вдалося визначити позицію. У Simulator обери Features > Location.',
      );
    }
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
          if (changed == true && mounted) {
            _loadEvents();
          }
        });
  }
}

class _LocationResult {
  const _LocationResult({this.location, this.notice});

  final LatLng? location;
  final String? notice;
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
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
