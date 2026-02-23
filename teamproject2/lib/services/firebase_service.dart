import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

// 1. Model สำหรับข้อมูลกราฟ
class WaterLevelData {
  final DateTime time;
  final double level;
  WaterLevelData({required this.time, required this.level});
}

// 2. Model สำหรับสถานะปัจจุบัน (ตรงกับ Firebase 100%)
class UmongStatus {
  final double lat;
  final double lng;
  final double percent;
  final double distance;
  final String color;
  final bool status;

  UmongStatus({
    required this.lat,
    required this.lng,
    required this.percent,
    required this.distance,
    required this.color,
    required this.status,
  });
}

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ดึงสถานะปัจจุบัน (Real-time)
  Stream<UmongStatus> getRealtimeStatus(String umongId) {
    return _dbRef.child(umongId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return UmongStatus(
        lat: (data['lat'] ?? 0).toDouble(),               
        lng: (data['lng'] ?? 0).toDouble(),               
        percent: (data['percent'] ?? 0).toDouble(),
        distance: (data['distance'] ?? 0).toDouble(),
        color: data['color'] ?? 'GRAY',
        status: data['status'] ?? false,
      );
    });
  }

  // ดึงประวัติ (History) สำหรับวาดกราฟแท่ง
  Stream<List<WaterLevelData>> getHistoryStream(String umongId) {
    return _dbRef
        .child(umongId)
        .child('history')
        .orderByChild('timestamp')
        .limitToLast(6) 
        .onValue
        .map((event) {
      final List<WaterLevelData> chartData = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        var sortedEntries = data.entries.toList()
          ..sort((a, b) => (a.value['timestamp'] as int).compareTo(b.value['timestamp'] as int));

        for (var entry in sortedEntries) {
          chartData.add(WaterLevelData(
            time: DateTime.fromMillisecondsSinceEpoch(entry.value['timestamp']),
            level: (entry.value['percent'] ?? 0).toDouble(),
          ));
        }
      }
      return chartData;
    });
  }

  // ล้างประวัติที่เกิน 6 แท่ง (FIFO)
  Future<void> cleanOldHistory(String umongId) async {
    try {
      final historyRef = _dbRef.child(umongId).child('history');
      final snapshot = await historyRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        if (data.length > 6) {
          var entries = data.entries.toList()
            ..sort((a, b) => (a.value['timestamp'] as int).compareTo(b.value['timestamp'] as int));
          
          int itemsToDelete = entries.length - 6;
          for (int i = 0; i < itemsToDelete; i++) {
            await historyRef.child(entries[i].key).remove();
          }
        }
      }
    } catch (e) {
      print("Error cleaning: $e");
    }
  }
}