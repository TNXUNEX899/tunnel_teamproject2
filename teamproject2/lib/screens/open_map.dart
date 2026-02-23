import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/utils/utils.dart';

import 'package:teamproject2/utils/tunnel_marker_manager.dart';
import 'package:teamproject2/widgets/weather_dashboard_widget.dart';
import 'package:teamproject2/widgets/dashboard_widget.dart';
import 'package:teamproject2/widgets/search_bar_widget.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  GoogleMapController? mapController;
  
  String? selectedUmongId;
  String? selectedLocationName;
  
  Set<Marker> _currentMarkers = {};
  late TunnelMarkerManager _markerManager;

  @override
  void initState() {
    super.initState();
    _markerManager = TunnelMarkerManager(
      onMarkersUpdated: (updatedMarkers) {
        setState(() {
          _currentMarkers = updatedMarkers;
        });
      },
      onMarkerTapped: (id, name) {
        setState(() {
          selectedUmongId = id;
          selectedLocationName = name;
        });
      },
    );
    
    _markerManager.startListening();
  }

  @override
  void dispose() {
    _markerManager.dispose();
    super.dispose();
  }

  void _goToLocation(Map<String, dynamic> location) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(location['lat'], location['lng']), 16)
    );
    setState(() {
      selectedUmongId = location['id'];
      selectedLocationName = location['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<CurrentLocationProvider>(
        builder: (context, locationProvider, child) {
          if(locationProvider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if(locationProvider.errorMessage.isNotEmpty){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showAppSnackbar(
                context: context, 
                type: SnackbarType.error,
                description: locationProvider.errorMessage
              );
            });
          }
          
          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: locationProvider.currentLocation,
                  zoom: 12,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                markers: _currentMarkers,
                onTap: (LatLng) {
                  setState(() {
                    selectedUmongId = null;
                    selectedLocationName = null;
                  });
                },
              ),

              SearchBarWidget(
                locations: _markerManager.tunnelLocations,
                onSelected: _goToLocation,
              ),

              DraggableScrollableSheet(
                initialChildSize: 0.35, 
                minChildSize: 0.15,
                maxChildSize: 0.9,
                builder: (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      children: [
                        Center(
                          child: Container(
                            width: 50, height: 5, margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        
                        if (selectedUmongId == null) 
                           const WeatherDashboardWidget()
                        else 
                           DashboardWidget(
                             umongId: selectedUmongId!,
                             locationName: selectedLocationName ?? '',
                           ),
                              
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}