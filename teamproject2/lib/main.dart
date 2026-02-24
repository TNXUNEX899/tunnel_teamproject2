import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teamproject2/screens/open_map.dart';
import 'package:teamproject2/provider/current_location_provider.dart'; 
import 'firebase_options.dart';

void main() async {
  // 1. Initialized ตะกร้าของ Flutter และ Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. เอา Provider ครอบไว้บนสุดของแอป (ครอบ MyApp)
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
    // 3. มี MaterialApp แค่ตัวเดียว
    return MaterialApp(
      title: 'Flood Tunnel Alert',
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug มุมขวาบน
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const OpenMap(), // กำหนดให้หน้า OpenMap เป็นหน้าแรกของแอป
    );
  }
}