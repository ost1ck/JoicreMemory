import 'package:joicrememory/l10n/localization.dart';
import 'package:flutter/material.dart';
import '../../../app/app_scope.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
    final result = await AppScope.read(context).location.currentLocation();
    final location = result.location;
    return location == null
        ? null
        : LatLng(location.latitude, location.longitude);
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
        title: Text(context.l10n.eventLocation),
        actions: [
          IconButton(
            onPressed:
                _isLocating
                    ? null
                    : () => _centerOnCurrentLocation(selectLocation: true),
            icon: Icon(Icons.my_location_outlined),
            tooltip: context.l10n.myLocation,
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
                  markerId: MarkerId('selected_event_location'),
                  position: selectedLocation,
                  draggable: true,
                  onDragEnd: _selectLocation,
                  infoWindow: InfoWindow(title: context.l10n.eventLocation),
                ),
            },
            myLocationEnabled: _canShowUserLocation,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (_isLocating)
            Positioned.fill(child: Center(child: CircularProgressIndicator())),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            selectedLocation == null
                                ? Icons.place_outlined
                                : Icons.check_circle_outline,
                            color:
                                selectedLocation == null
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedLocation == null
                                  ? context.l10n.noPinSelectedYet
                                  : context.l10n.mapLocationSelected,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        selectedLocation == null
                            ? null
                            : () => Navigator.of(context).pop(selectedLocation),
                    icon: Icon(Icons.check),
                    label: Text(context.l10n.useThisLocation),
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
