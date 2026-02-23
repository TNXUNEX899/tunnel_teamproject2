import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teamproject2/services/firebase_service.dart';

class TunnelMarkerManager {
  final FirebaseService _firebaseService = FirebaseService();
  
  final Function(Set<Marker>) onMarkersUpdated;
  final Function(String id, String name) onMarkerTapped;

  // ⭐️ กำหนดชื่อสถานที่ให้ตรงกับ Node ID ใน Firebase
  final Map<String, String> umongNames = {
    'umong': 'อุโมงค์ทางลอดแยกศรีอุดม',
    'umong2': 'อุโมงค์ทางลอดแยกมไหสวรรย์',
  };

  List<Map<String, dynamic>> tunnelLocations = [];
  final Map<String, Marker> _markers = {};
  final List<StreamSubscription> _subscriptions = [];

  TunnelMarkerManager({
    required this.onMarkersUpdated,
    required this.onMarkerTapped,
  });

  void startListening() {
    for (var id in umongNames.keys) {
      var sub = _firebaseService.getRealtimeStatus(id).listen((status) {
        
        // ถ้าพิกัดเป็น 0 ถือว่ายังไม่มีข้อมูลให้ข้ามไปก่อน
        if (status.lat == 0 && status.lng == 0) return;

        String locationName = umongNames[id]!; 

        _updateSearchData(id, locationName, status.lat, status.lng);
        _updateMarker(id, locationName, status.lat, status.lng, status.color);
      });
      
      _subscriptions.add(sub);
    }
  }

  void _updateSearchData(String id, String name, double lat, double lng) {
    tunnelLocations.removeWhere((element) => element['id'] == id);
    tunnelLocations.add({
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
    });
  }

  void _updateMarker(String id, String name, double lat, double lng, String colorStr) {
    final marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(colorStr)),
      onTap: () => onMarkerTapped(id, name),
    );

    _markers[id] = marker; 
    onMarkersUpdated(_markers.values.toSet());
  }

  double _getMarkerHue(String colorStr) {
    switch (colorStr.toUpperCase()) {
      case 'RED': return BitmapDescriptor.hueRed;
      case 'YELLOW': return BitmapDescriptor.hueOrange;
      case 'GREEN': return BitmapDescriptor.hueGreen;
      default: return BitmapDescriptor.hueAzure; 
    }
  }

  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
  }
}