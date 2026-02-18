//ค้นหาตำแหน่ง GPS ของ user และแสดงบนแผนที่
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationProvider extends ChangeNotifier {
  //default : กรุงเทพ
  LatLng _currentLocation = LatLng(13.7278, 100.5241); // ค่าเริ่มต้นของตำแหน่งปัจจุบัน
  bool _isLoading = true;
  String _errorMessage = '';
  //public getters to access private varibales
  LatLng get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  CurrentLocationProvider() {
    _getCurrentLocation();
  }

  //main function to get device's current location
  Future<void> _getCurrentLocation() async {
    try {
      //check if location permission is granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        //request permission if denied
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      //check if permission is permanently denied
      if(permission == LocationPermission.deniedForever) {
        _errorMessage =
            'Location permissions are permanently denied. Using default location.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      //check if location service are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      //get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      //success - update location nad clear loading/error states
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
      _errorMessage = "";
      notifyListeners();
    } catch (e) {
      //handle any error during location retrival
      _errorMessage = "Error getting location: ${e.toString()}. Use default location.";
      _isLoading = false;
      notifyListeners();
    } 
  }
  //public method to manually refresh location (can be call by ui)
  void refreshLocation() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    _getCurrentLocation();
  }

}