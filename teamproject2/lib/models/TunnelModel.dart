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

  factory TunnelModel.fromMap(String id, Map<dynamic, dynamic> map) { // เปลี่ยนชื่อ factory
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

  // เผื่อต้องส่งค่ากลับขึ้น Firebase (ตอนนี้ยังไม่ได้ใช้ แต่มีไว้ดีกว่า)
  // Map<String, dynamic> toMap() {
  //   return {
  //     'color': color,
  //     'distance': distance,
  //     'lat': latitude,
  //     'lng': longitude,
  //     'percent': percent,
  //     'status': status,
  //   };
  // }
}