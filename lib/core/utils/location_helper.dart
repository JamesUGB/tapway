// lib/core/utils/location_helper.dart
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Future<LatLng> getCurrentLatLng() async {
    final position = await getCurrentLocation();
    return LatLng(position.latitude, position.longitude);
  }

  static double calculateDistance(LatLng start, LatLng end) {
    final Distance distance = Distance();
    return distance(start, end);
  }

  static double calculateDistanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    final Distance distance = Distance();
    return distance(
      LatLng(startLat, startLng),
      LatLng(endLat, endLng),
    );
  }
}