import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';

class EventLocationPickerScreen extends StatefulWidget {
  const EventLocationPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<EventLocationPickerScreen> createState() =>
      _EventLocationPickerScreenState();
}

class _EventLocationPickerScreenState extends State<EventLocationPickerScreen> {
  static const _lviv = LatLng(49.8397, 24.0297);

  GoogleMapController? _mapController;
  late LatLng _cameraTarget;
  LatLng? _selectedLocation;
  bool _canShowUserLocation = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _cameraTarget = widget.initialLocation ?? _lviv;
    _selectedLocation = widget.initialLocation;

    if (widget.initialLocation == null) {
      _centerOnCurrentLocation(selectLocation: false);
    }
  }

  Future<void> _centerOnCurrentLocation({bool selectLocation = true}) async {
    setState(() => _isLocating = true);

    try {
      final location = await _resolveCurrentLocation();

      if (location == null || !mounted) {
        return;
      }

      setState(() {
        _cameraTarget = location;
        _canShowUserLocation = true;
        if (selectLocation) {
          _selectedLocation = location;
        }
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<LatLng?> _resolveCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 8),
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _cameraTarget = location;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = _selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Місце події'),
        actions: [
          IconButton(
            onPressed:
                _isLocating
                    ? null
                    : () => _centerOnCurrentLocation(selectLocation: true),
            icon: const Icon(Icons.my_location_outlined),
            tooltip: 'Моя позиція',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _cameraTarget,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (selectedLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(selectedLocation, 15),
                );
              }
            },
            onTap: _selectLocation,
            markers: {
              if (selectedLocation != null)
                Marker(
                  markerId: const MarkerId('selected_event_location'),
                  position: selectedLocation,
                  draggable: true,
                  onDragEnd: _selectLocation,
                  infoWindow: const InfoWindow(title: 'Місце події'),
                ),
            },
            myLocationEnabled: _canShowUserLocation,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (_isLocating)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            selectedLocation == null
                                ? Icons.place_outlined
                                : Icons.check_circle_outline,
                            color:
                                selectedLocation == null
                                    ? AppColors.rosyGranite
                                    : AppColors.leaf,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedLocation == null
                                  ? 'Точку ще не обрано'
                                  : 'Місце на мапі обрано',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        selectedLocation == null
                            ? null
                            : () => Navigator.of(context).pop(selectedLocation),
                    icon: const Icon(Icons.check),
                    label: const Text('Використати місце'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
