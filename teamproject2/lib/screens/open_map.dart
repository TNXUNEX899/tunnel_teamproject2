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

  final DraggableScrollableController _sheetController = DraggableScrollableController();

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
        
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.45,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      },
    );
    
    _markerManager.loadCustomPins().then((_) {
      _markerManager.startListening();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
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

    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.45,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShowingWeather = selectedUmongId == null;

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
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false, // เราปิดของเดิมไว้เพื่อใช้ปุ่มที่เราแต่งเอง
                mapType: MapType.normal,
                markers: _currentMarkers,
                onTap: (LatLng) {
                  FocusScope.of(context).unfocus(); // ซ่อนแป้นพิมพ์ถ้าเปิดอยู่
                  setState(() {
                    selectedUmongId = null;
                    selectedLocationName = null;
                  });
                  
                  if (_sheetController.isAttached) {
                    _sheetController.animateTo(
                      0.40,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),

              SearchBarWidget(
                locations: _markerManager.tunnelLocations,
                onSelected: _goToLocation,
              ),

              // ⭐️ เพิ่มปุ่ม "กลับตำแหน่งปัจจุบัน" ตรงนี้ครับ
              Positioned(
                top: 130, // ระยะห่างจากด้านบน (ให้อยู่ใต้ช่องค้นหาพอดี)
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: Color(0xFF5D7B93)), // ใช้สีโทนเดียวกับ UI สภาพอากาศ
                    onPressed: () {
                      // สั่งให้กล้องบินกลับไปที่พิกัดปัจจุบัน
                      mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          locationProvider.currentLocation, // ดึงพิกัดจาก GPS
                          16.0, // ระดับการซูม (ยิ่งมากยิ่งใกล้)
                        ),
                      );
                    },
                  ),
                ),
              ),

              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: isShowingWeather ? 0.40 : 0.45, 
                minChildSize: 0.05, 
                maxChildSize: isShowingWeather ? 0.40 : 0.70, 
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
                        
                        if (isShowingWeather) 
                           const WeatherDashboardWidget()
                        else 
                           DashboardWidget(
                             umongId: selectedUmongId!,
                             locationName: selectedLocationName ?? '',
                           ),
                              
                        SizedBox(height: isShowingWeather ? 0 : 16), 
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