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

  //callback when google map is ready
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //create markers for current location on map(ตัวอย่าง)
  // Set<Marker> _buildMarkers(LatLng currentLocation) {
  //   return {
  //     Marker(
  //       markerId: MarkerId("current_location"),
  //       position: currentLocation,
  //       infoWindow: InfoWindow(
  //         title: "Current Location",
  //         snippet: "You are here!",
  //       ),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //     ),
  //   };
  // }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<CurrentLocationProvider>(
        builder: (context, locationProvider, child) {
          //show loading spinner while getting location
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
          //show loading spinner while getting location
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
              //display the googlemap
              GoogleMap(
                onMapCreated: _onMapCreated,
                //markers: _buildMarkers(locationProvider.currentLocation),
                initialCameraPosition: CameraPosition(
                  target: locationProvider.currentLocation,
                  zoom: 17,
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