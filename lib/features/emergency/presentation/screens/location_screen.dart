// lib/features/emergency/presentation/screens/location_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/location_helper.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(0, 0);
  bool _isLoading = true;
  String _errorMessage = '';
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await LocationHelper.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      
      // Wait for the map to be initialized before moving
      if (_mapInitialized) {
        _mapController.move(_currentLocation, 15.0);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to get location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onMapReady() {
    setState(() {
      _mapInitialized = true;
    });
    
    // Move to current location once the map is ready
    if (!_isLoading && _errorMessage.isEmpty) {
      _mapController.move(_currentLocation, 15.0);
    }
  }

  void _handleBackNavigation() {
    // Get the previous route arguments if any
    final args = Get.arguments as Map<String, dynamic>?;
    final fromTab = args?['fromTab'] as int?;
    
    if (fromTab != null) {
      // Navigate back to the main screen with the specific tab
      Get.offNamedUntil('/main', (route) => false, arguments: {'initialTab': fromTab});
    } else {
      // Check if we can go back in the navigation stack
      if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/') {
        Get.back();
      } else {
        // Default fallback - go to main screen with Tapway tab (index 1)
        Get.offNamedUntil('/main', (route) => false, arguments: {'initialTab': 1});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackNavigation,
        ),
        title: const Text(
          'Map Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency information text
            const Text(
              'Emergency Personnel is on the way',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We\'ve shared your exact location with responders. Stay where you are and keep your phone accessible.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Map or loading/error state
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation,
                            initialZoom: 15.0,
                            onMapReady: _onMapReady,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.tapway',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_mapInitialized && !_isLoading) {
            _mapController.move(_currentLocation, 15.0);
          } else {
            _getUserLocation();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}