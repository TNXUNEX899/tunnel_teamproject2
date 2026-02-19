import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/utils/utils.dart';
// import 'package:teamproject2/services/api_service.dart';
// import 'package:teamproject2/services/firebase_service.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  GoogleMapController? mapController;
  bool isOnline = true;

  // final WeatherApiService _weatherApiService = WeatherApiService();
  // final FirebaseService _firebaseService = FirebaseService();

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

// void _testFetchData() async {
//     print("===== เริ่มทำการทดสอบดึงข้อมูล =====");

//     // --- ทดสอบ Weather API ---
//     try {
//       // ลองดึงข้อมูลของพิกัดกรุงเทพฯ เป็นตัวอย่าง
//       final weatherData = await _weatherApiService.getHourlyForecast(13.7278, 100.5241);
//       final current = weatherData['current'];
//       print("✅ [Weather API] สำเร็จ! ข้อมูลสถานที่: ${weatherData['location']['name']}");
//       print("🌡️ อุณหภูมิ: ${current['temp_c']} °C");
//       print("☁️ สภาพอากาศ: ${current['condition']['text']}");
//       print("💧 ความชื้น: ${current['humidity']}%");
//       print("💨 ความเร็วลม: ${current['wind_kph']} กม./ชม.");
//       print("🕶️ ค่า UV Index: ${current['uv']}");
//     } catch (e) {
//       print("❌ [Weather API] เกิดข้อผิดพลาด: $e");
//     }

//     // --- ทดสอบ Firebase Realtime ---
//     // หมายเหตุ: เปลี่ยน 'umong1' เป็นชื่อ Node หรือ ID อุโมงค์ที่คุณใช้จริงใน Realtime Database
//     try {
//       _firebaseService.getRealtimeStatus('umong2').listen((status) {
//         print("✅ [Firebase Realtime] ข้อมูลอัปเดต: เปอร์เซ็นต์ = ${status.percent}%, สถานะ = ${status.status}, สี = ${status.color}");
//       }, onError: (e) {
//         print("❌ [Firebase Realtime] เกิดข้อผิดพลาด: $e");
//       });
//     } catch (e) {
//       print("❌ [Firebase Realtime] เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
//     }

//     // --- ทดสอบ Firebase History ---
//     try {
//       _firebaseService.getHistoryStream('umong2').listen((historyList) {
//         print("✅ [Firebase History] ดึงประวัติสำเร็จ: ได้ข้อมูลมาทั้งหมด ${historyList.length} รายการ");
//         if (historyList.isNotEmpty) {
//           print("   -> รายการล่าสุดเมื่อเวลา: ${historyList.last.time}, ระดับน้ำ: ${historyList.last.level}");
//         }
//       }, onError: (e) {
//         print("❌ [Firebase History] เกิดข้อผิดพลาด: $e");
//       });
//     } catch (e) {
//       print("❌ [Firebase History] เกิดข้อผิดพลาดในการเชื่อมต่อ: $e");
//     }
    
//     print("================================");
//   }

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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _testFetchData,
      //   backgroundColor: Colors.deepPurple,
      //   child: const Icon(Icons.bug_report, color: Colors.white),
      // ),
    );
  }
}