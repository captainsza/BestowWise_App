import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

Completer<GoogleMapController> _controller = Completer();
bool isMapCreated = false;

Future<LatLng?> showLocationPicker(BuildContext context) async {
  // Request user's current location
  Location location = Location();
  LocationData? locationData = await location.getLocation();

  // ignore: use_build_context_synchronously
  return showDialog<LatLng>(
    context: context,
    builder: (context) {
      LatLng? pickedLocation;
      return AlertDialog(
        title: const Text('Select a Location'),
        content: SizedBox(
          height: 300.0,
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              if (!isMapCreated) {
                isMapCreated = true;
                _controller.complete(controller);

                // Move camera to user's current location
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(locationData.latitude!, locationData.longitude!),
                    14.0,
                  ),
                );
              }
            },
            onTap: (LatLng latLng) {
              pickedLocation = latLng;
              if (isMapCreated) {
                _controller.future.then((controller) {
                  controller.animateCamera(CameraUpdate.newLatLng(latLng));
                });
              }
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.422, -122.084),
              zoom: 14.0,
            ),
            myLocationEnabled: true, // Enable current location button
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(pickedLocation);
            },
            child: const Text('Select'),
          ),
        ],
      );
    },
  );
}
// Completer<GoogleMapController> _controller = Completer();
// bool isMapCreated = false;

// Future<LatLng?> showLocationPicker(BuildContext context) async {
//   return showDialog<LatLng>(
//     context: context,
//     builder: (context) {
//       LatLng? pickedLocation;

//       return AlertDialog(
//         title: const Text('Select a Location'),
//         content: SizedBox(
//           height: 300.0,
//           child: GoogleMap(
//             onMapCreated: (GoogleMapController controller) {
//               if (!isMapCreated) {
//                 isMapCreated = true;
//                 _controller.complete(controller);
//               }
//             },
//             onTap: (LatLng latLng) {
//               pickedLocation = latLng;
//               if (isMapCreated) {
//                 _controller.future.then((controller) {
//                   controller.animateCamera(CameraUpdate.newLatLng(latLng));
//                 });
//               }
//             },
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(37.422, -122.084),
//               zoom: 14.0,
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(pickedLocation);
//             },
//             child: const Text('Select'),
//           ),
//         ],
//       );
//     },
//   );
// }
