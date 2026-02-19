// คลาสเดิมของคุณ (สำหรับค่า Real-time)
class TunnelModel {
  final String id;
  final String color;
  final double distance;
  final double latitude;
  final double longitude;
  final int percent;
  final bool status;

  TunnelModel({
    required this.id,
    required this.color,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.percent,
    required this.status,
  });

  factory TunnelModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return TunnelModel(
      id: id,
      color: map['color'] ?? 'UNKNOWN',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      latitude: (map['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['lng'] as num?)?.toDouble() ?? 0.0,
      percent: (map['percent'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? false,
    );
  }
}

// เพิ่มคลาสนี้เข้าไปข้างล่าง (สำหรับข้อมูลกราฟโดยเฉพาะ)
class WaterLevelHistory {
  final DateTime time;
  final double percent;

  WaterLevelHistory({required this.time, required this.percent});

  factory WaterLevelHistory.fromMap(Map<dynamic, dynamic> map) {
    return WaterLevelHistory(
      // แปลงจาก timestamp ที่ ESP32 ส่งมา
      time: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      percent: (map['percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}