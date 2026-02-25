import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// TODO: เช็ค path ให้ตรงกับโปรเจกต์ของคุณ
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/screens/open_map.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ตัวแปรเช็คว่ากำลังจะเปลี่ยนหน้าแล้วหรือยัง (ป้องกันการเด้งหน้าซ้ำ)
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    // ⭐️ ใช้ Consumer เพื่อดักฟังว่าระบบหา GPS เสร็จหรือยัง
    return Consumer<CurrentLocationProvider>(
      builder: (context, locationProvider, child) {
        
        // ถ้า isLoading เป็น false (หาตำแหน่งเสร็จแล้ว หรือเกิด Error แล้ว)
        if (!locationProvider.isLoading && !_isNavigating) {
          _isNavigating = true; 
          
          // โชว์โลโก้ค้างไว้อีก 1.5 วินาที เพื่อไม่ให้มันเด้งเปลี่ยนหน้าเร็วจนเกินไป
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
            // ⭐️ ลบวงกลมโหลดออก เหลือแค่รูปโลโก้อย่างเดียว
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