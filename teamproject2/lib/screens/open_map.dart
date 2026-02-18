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