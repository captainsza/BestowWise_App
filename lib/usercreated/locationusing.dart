import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String?> getCurrentLocation() async {
  String? location;

  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if (isLocationEnabled) {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      location = "${placemark.locality}, ${placemark.country}";
    }
  } else {
    await Geolocator.openLocationSettings();
  }

  return location;
}
