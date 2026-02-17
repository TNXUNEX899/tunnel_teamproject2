//Realtime Database
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // สร้างตัวแปรอ้างอิงไปยัง Realtime Database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ฟังก์ชันดึงค่า percent แบบ Realtime (Stream)
  Stream<DatabaseEvent> getWaterLevelStream() {
    return _dbRef.child('percent').onValue;
  }

  // ถ้าอยากดึงค่าอื่นๆ เพิ่ม เช่น status หรือ color ก็ทำเพิ่มได้ตรงนี้
  Stream<DatabaseEvent> getStatusStream() {
    return _dbRef.child('status').onValue;
  }
}