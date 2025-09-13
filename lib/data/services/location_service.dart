// lib/data/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo; // Added with proper import

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // optional, can ignore if you don’t need it
    ),
  );
  }

  Future<Map<String, String?>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(latitude, longitude); 
      if (placemarks.isEmpty) return {};

      final place = placemarks.first;
      return {
        'street': place.street,
        'barangay': place.subLocality ?? place.locality,
        'city': place.locality,
        'province': place.administrativeArea,
        'landmark': place.name,
        'formattedAddress': [
          if (place.street != null) place.street,
          if (place.subLocality != null) place.subLocality,
          if (place.locality != null) place.locality,
          if (place.administrativeArea != null) place.administrativeArea,
          if (place.country != null) place.country,
        ].join(', '),
      };
    } catch (e) {
      return {};
    }
  }
}