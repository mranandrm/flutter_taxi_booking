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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {

  String _location = "Press the button to get location";
  bool _isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _location = "Fetching location...";
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = "Location services are disabled.";
          _isLoading = false;
        });
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Location permissions are denied.";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location =
          "Location permissions are permanently denied. Please enable them in settings.";
          _isLoading = false;
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _location = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _location =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _location = "No address available for this location.";
        });
      }
    } catch (e) {
      setState(() {
        _location = "Failed to get address: $e";
      });
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Get Current Location")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
          _location,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}