// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
//
// class LocationScreen extends StatefulWidget {
//   @override
//   _LocationScreenState createState() => _LocationScreenState();
// }
//
// class _LocationScreenState extends State<LocationScreen> {
//   String _location = "Press the button to get location";
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         _location = "Location services are disabled.";
//       });
//       return;
//     }
//
//     // Check location permission
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           _location = "Location permissions are denied.";
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         _location = "Location permissions are permanently denied.";
//       });
//       return;
//     }
//
//     // Get the current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     setState(() {
//       _location = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Get Current Location")),
//       body: Center(child: Text(_location, textAlign: TextAlign.center)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _getCurrentLocation,
//         child: Icon(Icons.location_on),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _location = "Press button to get location";
  bool _loading = false;

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _location = "Fetching location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = "Location services disabled.";
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Location permission denied.";
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location =
          "Location permissions permanently denied. Enable from settings.";
          _loading = false;
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> marks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);

      Placemark place = marks.first;

      setState(() {
        _location = "${place.street}, ${place.locality}, ${place.country}";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _location = "Error: $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Screen")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text(
          _location,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
