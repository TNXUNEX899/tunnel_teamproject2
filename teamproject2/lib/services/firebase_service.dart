import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:teamproject2/models/TunnelModel.dart';

class FirebaseService {
  // สร้าง Reference ไปยัง Root ของ Database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ----------------------------------------------------------------
  // 1. ฟังก์ชัน Stream: ดึงข้อมูลทั้งหมดแบบ Realtime
  // ใช้สำหรับแสดงหมุดบนแผนที่ (Map) และรายการในหน้าค้นหา
  // ----------------------------------------------------------------
  Stream<List<TunnelModel>> getTunnelStream() {
    // เข้าไปที่ Node ชื่อ 'umong' ตามภาพ Database ของคุณ
    return _dbRef.child('umong').onValue.map((event) {
      final List<TunnelModel> tunnels = [];
      
      // ดึงข้อมูลดิบออกมา (Map<Key, Value>)
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          try {
            // key = ชื่อ ID (เช่น "umong", "umong2")
            // value = ข้อมูลข้างใน (lat, lng, color, etc.)
            final tunnel = TunnelModel.fromMap(
              key.toString(), 
              value as Map<dynamic, dynamic>
            );
            tunnels.add(tunnel);
          } catch (e) {
            print("Error parsing tunnel '$key': $e");
          }
        });
      }
      return tunnels;
    });
  }

  // ----------------------------------------------------------------
  // 2. ฟังก์ชัน Get By ID: ดึงข้อมูลเฉพาะเจาะจงตาม ID
  // ใช้สำหรับหน้า Dashboard เวลาUser กดเลือกหมุดนั้นๆ
  // ----------------------------------------------------------------
  Future<TunnelModel?> getTunnelById(String id) async {
    try {
      // ดึงข้อมูลจาก path: umong/ชื่อID
      final snapshot = await _dbRef.child('umong/$id').get();

      if (snapshot.exists && snapshot.value != null) {
        return TunnelModel.fromMap(
          id, 
          snapshot.value as Map<dynamic, dynamic>
        );
      }
    } catch (e) {
      print("Error fetching tunnel details: $e");
    }
    return null; // ถ้าหาไม่เจอ หรือ Error ให้คืนค่าว่าง
  }
}