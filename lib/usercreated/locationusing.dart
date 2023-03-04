import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String?> getCurrentLocation() async {
  String? location;

  // Check if location services are enabled
  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if (isLocationEnabled) {
    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get the city and country names from the position
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      location = "${placemark.locality}, ${placemark.country}";
    }
  } else {
    // Prompt the user to enable location services
    await Geolocator.openLocationSettings();
  }

  return location;
}
