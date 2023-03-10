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

// Future<String?> getSelectedLocation() async {
//   String? location;

//   // Prompt the user to select a location from the map
//   LatLng? latLng = await MapsLauncher.launchMap(
//     zoom: 15,
//     title: "Select Location",
//     markerIcon:
//         BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//   );

//   if (latLng != null) {
//     // Get the city and country names from the selected location
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

//     if (placemarks.isNotEmpty) {
//       Placemark placemark = placemarks[0];
//       location = "${placemark.locality}, ${placemark.country}";
//     }
//   }

//   return location;
// }
