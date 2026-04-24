import 'package:cloud_user/core/models/location_model.dart';
import 'package:cloud_user/core/theme/app_theme.dart';
import 'package:cloud_user/features/location/data/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default: New Delhi
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Attempt to get real location
    await ref.read(userLocationProvider.notifier).determinePosition();
    final location = ref.read(userLocationProvider);
    
    if (location != null) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(location.latitude, location.longitude);
          _isLoading = false;
        });
      }
    } else {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  void _confirmLocation() {
    // Update Provider with the center of the map
    ref.read(userLocationProvider.notifier).setLocation(
      LocationModel(
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
        address: "Pinned Location", // Real Geocoding would happen here
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          
          // Center Pin
          const Center(
            child: Icon(Icons.location_on, size: 48, color: AppTheme.primary),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.adaptive.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          
          // Confirm Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              child: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
