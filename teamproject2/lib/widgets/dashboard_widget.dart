import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
// TODO: แก้ไข path ให้ตรงกับที่เก็บไฟล์ของคุณ
import 'package:teamproject2/services/firebase_service.dart';

class DashboardWidget extends StatefulWidget {
  final String umongId;
  final String locationName;

  const DashboardWidget({Key? key, required this.umongId, required this.locationName}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final FirebaseService _firebaseService = FirebaseService();

  Color _mapStatusColor(String colorStr) {
    switch (colorStr.toUpperCase()) {
      case 'RED': return Colors.redAccent;
      case 'YELLOW': return Colors.orangeAccent;
      case 'GREEN': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _mapStatusText(bool status) {
    return status ? 'ปกติ (Normal)' : 'แจ้งเตือน (Alert)';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UmongStatus>(
      stream: _firebaseService.getRealtimeStatus(widget.umongId),
      builder: (context, statusSnapshot) {
        if (statusSnapshot.connectionState == ConnectionState.waiting) {
           return const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())));
        }

        final statusData = statusSnapshot.data;
        final percent = statusData?.percent ?? 0.0;
        final statusBool = statusData?.status ?? true;
        final colorStr = statusData?.color ?? 'GRAY';
        
        final statusColor = _mapStatusColor(colorStr);
        final currentTime = DateFormat('HH:mm').format(DateTime.now());

        return Column(
          children: [
            // --- Card ส่วนบน: แสดงสถานะปัจจุบัน ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // --- อัปเดตแก้ปัญหาชื่อยาวล้นจอ (Overflow) ตรงนี้ครับ ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start, // ให้ข้อความชิดบน
                      children: [
                        Expanded( // ใช้ Expanded เพื่อให้ชื่อตัดขึ้นบรรทัดใหม่
                          child: Text(
                            widget.locationName, 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 2, // ตัดขึ้นบรรทัดใหม่ได้สูงสุด 2 บรรทัด
                            overflow: TextOverflow.ellipsis, // ถ้าเกินให้ใส่จุด ...
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'เวลา $currentTime น.', 
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15), // เปลี่ยนสีพื้นหลังตามสถานะ
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.directions_car, size: 64, color: statusColor),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _buildStatusRow('ปริมาตรน้ำ :', '${percent.toStringAsFixed(1)} %'),
                              const SizedBox(height: 12),
                              _buildStatusRow('สถานะ:', _mapStatusText(statusBool), valueColor: statusColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // --- Card ส่วนล่าง: แสดงกราฟประวัติ ---
            StreamBuilder<List<WaterLevelData>>(
              stream: _firebaseService.getHistoryStream(widget.umongId),
              builder: (context, historySnapshot) {
                final historyList = historySnapshot.data ?? [];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('CHART', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Container(width: 10, height: 10, color: const Color(0xFF2E3A8C)),
                                const SizedBox(width: 8),
                                Text('ระดับน้ำ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 200,
                          child: historyList.isEmpty
                              ? const Center(child: Text('ไม่มีข้อมูลประวัติ'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: 100,
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= 0 && value.toInt() < historyList.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  DateFormat('HH.mm').format(historyList[value.toInt()].time),
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            if (value % 10 == 0) return Text(value.toInt().toString(), style: TextStyle(fontSize: 12, color: Colors.grey[600]));
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 10,
                                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: historyList.asMap().entries.map((entry) {
                                      return BarChartGroupData(
                                        x: entry.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: entry.value.level,
                                            color: const Color(0xFF2E3A8C),
                                            width: 16,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87))),
      ],
    );
  }
}