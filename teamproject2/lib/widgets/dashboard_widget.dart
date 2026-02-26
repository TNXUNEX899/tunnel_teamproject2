import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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

  late Stream<UmongStatus> _statusStream;
  late Stream<List<WaterLevelData>> _historyStream;

  @override
  void initState() {
    super.initState();
    _initStreams(); 
  }

  @override
  void didUpdateWidget(DashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.umongId != widget.umongId) {
      _initStreams();
    }
  }

  void _initStreams() {
    _statusStream = _firebaseService.getRealtimeStatus(widget.umongId);
    _historyStream = _firebaseService.getHistoryStream(widget.umongId);
  }

  Color _mapStatusColor(String colorStr) {
    switch (colorStr.toUpperCase()) {
      case 'RED': return const Color(0xFFDF2B2B);    // สีแดง
      case 'YELLOW': return const Color(0xFFF2C94C); // สีเหลือง
      case 'GREEN': return const Color(0xFF3DCF4E);  // สีเขียว
      default: return Colors.grey;
    }
  }

  String _mapStatusText(String colorStr) {
    switch (colorStr.toUpperCase()) {
      case 'GREEN': return 'ปลอดภัย';
      case 'YELLOW': return 'ควรระวัง';
      case 'RED': return 'อันตราย';
      default: return 'ไม่ทราบสถานะ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return Column(
      children: [
        // --- ส่วนบน: สถานะปัจจุบัน ---
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline, 
                textBaseline: TextBaseline.alphabetic, 
                children: [
                  Expanded(
                    child: Text(
                      widget.locationName, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'เวลา $currentTime น.', 
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              StreamBuilder<UmongStatus>(
                stream: _statusStream,
                builder: (context, statusSnapshot) {
                  if (statusSnapshot.connectionState == ConnectionState.waiting && !statusSnapshot.hasData) {
                    return const SizedBox(
                      height: 140, 
                      child: Center(child: CircularProgressIndicator())
                    );
                  }

                  final statusData = statusSnapshot.data;
                  final percent = statusData?.percent ?? 0.0;
                  final colorStr = statusData?.color ?? 'GRAY'; 
                  
                  final statusColor = _mapStatusColor(colorStr);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: statusColor, 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car, size: 48, color: Colors.black),
                            Icon(Icons.waves, size: 36, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'ปริมาตรน้ำ : ${percent.toStringAsFixed(1)} %', 
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'สถานะ: ${_mapStatusText(colorStr)}', 
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // --- ส่วนล่าง: กราฟประวัติ ---
        StreamBuilder<List<WaterLevelData>>(
          stream: _historyStream, 
          builder: (context, historySnapshot) {
            final historyList = historySnapshot.data ?? [];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CHART', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      Row(
                        children: [
                          Container(width: 10, height: 10, color: const Color(0xFF1E2460)),
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
                              alignment: BarChartAlignment.start, 
                              groupsSpace: 35, // ⭐️ เพิ่มระยะห่างระหว่างแท่งตรงนี้
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
                              gridData: const FlGridData(
                                show: false, // เอาเส้นแนวนอนออก
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                                  left: BorderSide(color: Colors.grey[400]!, width: 1),
                                  top: BorderSide.none,
                                  right: BorderSide.none,
                                )
                              ),
                              barGroups: historyList.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.level,
                                      color: const Color(0xFF1E2460), 
                                      width: 26, // ⭐️ ปรับความกว้างแท่งให้อ้วนขึ้นเป็น 26
                                      borderRadius: BorderRadius.zero, 
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}