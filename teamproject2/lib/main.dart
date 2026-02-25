import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Initialized ตัวเชื่อมของ Flutter และ Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. เอา Provider ครอบไว้บนสุดของแอป (ครอบ MyApp) เพื่อให้แอปดึงตำแหน่ง GPS ได้ทุกหน้า
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentLocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug สีแดงมุมขวาบน
      title: 'Tunnel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E2460)),
        useMaterial3: true,
      ),
      // ⭐️ เปลี่ยนหน้าแรกเป็น SplashScreen แทน OpenMap
      home: const SplashScreen(), 
    );
  }
}