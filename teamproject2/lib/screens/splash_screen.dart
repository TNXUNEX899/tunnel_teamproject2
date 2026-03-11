import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/screens/open_map.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    //หา GPS เสร็จหรือยัง
    return Consumer<CurrentLocationProvider>(
      builder: (context, locationProvider, child) {
        
        //หาตำแหน่งเสร็จแล้ว หรือเกิด Error แล้ว
        if (!locationProvider.isLoading && !_isNavigating) {
          _isNavigating = true; 
          
          // โชว์โลโก้ค้างไว้อีก 1.5 วินาที ไม่ให้มันเด้งเปลี่ยนหน้าเร็วเกินไป
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const OpenMap()),
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Image.asset(
              'assets/tunnel.png',
              width: 180,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}