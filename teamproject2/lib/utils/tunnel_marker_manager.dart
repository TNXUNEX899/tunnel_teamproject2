import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teamproject2/services/firebase_service.dart';
import 'package:flutter/material.dart';

class TunnelMarkerManager {
  final FirebaseService _firebaseService = FirebaseService();
  
  final Function(Set<Marker>) onMarkersUpdated;
  final Function(String id, String name) onMarkerTapped;

  final Map<String, String> umongNames = {
    'umong': 'อุโมงค์ทางลอดแยกศรีอุดม',
    'umong2': 'อุโมงค์ทางลอดแยกมไหสวรรย์',
  };

  List<Map<String, dynamic>> tunnelLocations = [];
  final Map<String, Marker> _markers = {};
  final List<StreamSubscription> _subscriptions = [];

  BitmapDescriptor? _pinGreen;
  BitmapDescriptor? _pinYellow;
  BitmapDescriptor? _pinRed;
  BitmapDescriptor? _pinGray;

  TunnelMarkerManager({
    required this.onMarkersUpdated,
    required this.onMarkerTapped,
  });

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> loadCustomPins() async {
    //80 ถึง 120 pixels)
    int pinWidth = 100; 

    try {
      final greenBytes = await _getBytesFromAsset('assets/pin_green.png', pinWidth);
      _pinGreen = BitmapDescriptor.fromBytes(greenBytes);

      final yellowBytes = await _getBytesFromAsset('assets/pin_yellow.png', pinWidth);
      _pinYellow = BitmapDescriptor.fromBytes(yellowBytes);

      final redBytes = await _getBytesFromAsset('assets/pin_red.png', pinWidth);
      _pinRed = BitmapDescriptor.fromBytes(redBytes);
      
    } catch (e) {
      debugPrint('Error loading custom pins: $e');
    }
  }

  void startListening() {
    for (var id in umongNames.keys) {
      var sub = _firebaseService.getRealtimeStatus(id).listen((status) {
        
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
      icon: _getMarkerIcon(colorStr), 
      onTap: () => onMarkerTapped(id, name),
    );

    _markers[id] = marker; 
    onMarkersUpdated(_markers.values.toSet());
  }

  BitmapDescriptor _getMarkerIcon(String colorStr) {
    switch (colorStr.toUpperCase()) {
      case 'RED': 
        return _pinRed ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'YELLOW': 
        return _pinYellow ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'GREEN': 
        return _pinGreen ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default: 
        return _pinGray ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure); 
    }
  }

  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
  }
}