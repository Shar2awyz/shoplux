import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shoplux/constants/AppColors.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  static Future<String?> pick(BuildContext context) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerPage()),
    );
  }

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final _mapController = MapController();

  // Default center: Cairo, Egypt
  LatLng _markerPosition = const LatLng(30.0444, 31.2357);
  String _address = 'Tap on the map to select a location';
  bool _isLocating = false;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setAddress('Location permission denied. Tap the map to select.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _setAddress('Location permission permanently denied. Go to Settings to enable it.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final pos = LatLng(position.latitude, position.longitude);
      setState(() {
        _markerPosition = pos;
        _isLocating = false;
      });
      try {
        _mapController.move(pos, 16.0);
      } catch (_) {}
      _reverseGeocode(pos);
    } catch (_) {
      _setAddress('Could not detect location. Tap the map to select.');
    }
  }

  void _setAddress(String msg) {
    if (!mounted) return;
    setState(() {
      _address = msg;
      _isLocating = false;
      _isGeocoding = false;
    });
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _isGeocoding = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.subLocality?.isNotEmpty == true) p.subLocality!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        _setAddress(parts.isNotEmpty
            ? parts.join(', ')
            : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
      }
    } catch (_) {
      _setAddress(
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    }
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() => _markerPosition = point);
    _reverseGeocode(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _markerPosition,
              initialZoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shoplux.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _markerPosition,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_pin,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── GPS button ────────────────────────────────────────
          Positioned(
            bottom: 210,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _isLocating ? null : _goToCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(Icons.my_location,
                      color: AppColors.primary, size: 20),
            ),
          ),

          // ── Bottom address card ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C2E),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'SELECTED ADDRESS',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        if (_isGeocoding) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 11,
                            height: 11,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _address,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isGeocoding
                            ? null
                            : () => Navigator.of(context).pop(_address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
