import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class TaxiMapScreen extends StatefulWidget {
  @override
  _TaxiMapScreenState createState() => _TaxiMapScreenState();
}

class _TaxiMapScreenState extends State<TaxiMapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  String _selectedAddress = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // -------------------------------------------
  // 1. Get Current Location
  // -------------------------------------------
  Future<void> _getCurrentLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    });

    final GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 16),
    );
  }

  // -------------------------------------------
  // 2. Reverse Geocode (LatLng → Address)
  // -------------------------------------------
  Future<void> _reverseGeocode(LatLng position) async {
    List<Placemark> result =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (result.isNotEmpty) {
      final place = result.first;
      setState(() {
        _selectedAddress =
        "${place.name}, ${place.locality}, ${place.administrativeArea}";
      });
    }
  }

  // -------------------------------------------
  // 3. When user taps map
  // -------------------------------------------
  void _onMapTap(LatLng tappedPoint) async {
    setState(() {
      _selectedLocation = tappedPoint;
    });
    await _reverseGeocode(tappedPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // ---------------------------
          // Google Map
          // ---------------------------
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: _currentLocation!, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _controller.complete(controller),
            onTap: _onMapTap,
            markers: {
              if (_selectedLocation != null)
                Marker(
                  markerId: MarkerId("picked"),
                  position: _selectedLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                )
            },
          ),

          // --------------------------------------
          // Top Search Box (Google Places Search)
          // --------------------------------------
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: TextEditingController(),
              googleAPIKey: "YOUR_API_KEY",
              inputDecoration: InputDecoration(
                hintText: "Search Destination",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              debounceTime: 600,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (prediction) async {
                double lat =
                double.parse(prediction.lat.toString());
                double lng =
                double.parse(prediction.lng.toString());

                LatLng pos = LatLng(lat, lng);

                _onMapTap(pos);

                final GoogleMapController map =
                await _controller.future;
                map.animateCamera(
                    CameraUpdate.newLatLngZoom(pos, 16));
              },
              itemClick: (prediction) {},
            ),
          ),

          // ---------------------------
          // Bottom Address Card
          // ---------------------------
          if (_selectedLocation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Selected Location:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(_selectedAddress),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          "lat": _selectedLocation!.latitude,
                          "lng": _selectedLocation!.longitude,
                          "address": _selectedAddress,
                        });
                      },
                      child: Text("Confirm Location"),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
