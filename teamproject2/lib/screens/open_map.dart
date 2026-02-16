import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/utils/utils.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  GoogleMapController? mapController;
  bool isOnline = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Set<Marker> _buildMarkers(LatLng currentLocation) {
  //   return {
  //     Marker(
  //       markerId: MarkerId("current_location"),
  //       position: currentLocation,
  //       infoWindow: InfoWindow(
  //         title: "You are here",
  //         snippet: "You are here"),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //     ),
  //   };
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<CurrentLocationProvider>(
        builder: (context, locationProvider, child) {
          if(locationProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Getting your location..."),
                ],
              ),
            );
          }
          if(locationProvider.errorMessage.isNotEmpty){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAppSnackbar(
                context: context, 
                type: SnackbarType.error,
                description: locationProvider.errorMessage);
            });
          }
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                // markers: _buildMarkers(locationProvider.currentLocation),
                initialCameraPosition: CameraPosition(
                  target: locationProvider.currentLocation,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
              ),
              
            ],
          );
        },
      ),
    );
  }
}