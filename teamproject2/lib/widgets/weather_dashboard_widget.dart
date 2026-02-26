import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject2/provider/current_location_provider.dart';
import 'package:teamproject2/services/api_service.dart';

class WeatherDashboardWidget extends StatefulWidget {
  const WeatherDashboardWidget({Key? key}) : super(key: key);

  @override
  State<WeatherDashboardWidget> createState() => _WeatherDashboardWidgetState();
}

class _WeatherDashboardWidgetState extends State<WeatherDashboardWidget> {
  final WeatherApiService _weatherApiService = WeatherApiService();
  Future<Map<String, dynamic>>? _weatherFuture;

  final Color _primaryTextColor = const Color(0xFF5D7B93);

  String _getWeatherIconAsset(String conditionText, bool isDay) {
    String condition = conditionText.toLowerCase();
    
    if (condition.contains('thunder') || condition.contains('storm')) {
      if (condition.contains('rain')) return 'assets/stromrain.png'; 
      return 'assets/thunder.png';
    } 
    else if (condition.contains('patchy') || condition.contains('light')) {
      if (condition.contains('rain') || condition.contains('drizzle')) {
        return isDay ? 'assets/sunrain.png' : 'assets/moonrain.png';
      }
    }
    else if (condition.contains('rain') || condition.contains('shower')) {
      return 'assets/rain.png';
    } 
    else if (condition.contains('partly cloudy')) {
      return isDay ? 'assets/suncloud.png' : 'assets/mooncloud.png';
    }
    else if (condition.contains('cloud') || condition.contains('overcast') || condition.contains('fog') || condition.contains('mist')) {
      return 'assets/cloudy.png'; 
    } 
    else if (condition.contains('clear') || condition.contains('sunny')) {
      return isDay ? 'assets/sun.png' : 'assets/moonstar.png';
    }
    
    return isDay ? 'assets/sun.png' : 'assets/moonstar.png';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentLocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.isLoading) {
          return _buildLoadingCard();
        }

        if (locationProvider.errorMessage.isNotEmpty) {
          return _buildErrorCard(locationProvider.errorMessage);
        }

        final lat = locationProvider.currentLocation.latitude;
        final lon = locationProvider.currentLocation.longitude;
        _weatherFuture ??= _weatherApiService.getHourlyForecast(lat, lon);

        return FutureBuilder<Map<String, dynamic>>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            } else if (snapshot.hasError) {
              return _buildErrorCard('เกิดข้อผิดพลาดในการดึงข้อมูลสภาพอากาศ');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return _buildErrorCard('ไม่พบข้อมูลสภาพอากาศ');
            }

            final current = snapshot.data!['current'];
            final temp = current['temp_c'].toInt();
            final conditionText = current['condition']['text'];
            
            final isDay = current['is_day'] == 1; 
            
            final windKmh = current['wind_kph'];
            final humidity = current['humidity'];
            final uv = current['uv'];

            final weatherAssetPath = _getWeatherIconAsset(conditionText, isDay);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ⭐️ ใช้ Stack เพื่อซ้อนแสงเงาไว้หลังรูป โดยไม่ตัดขอบรูป
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // ชั้นที่ 1: แสง Glow สีส้ม (ทำเป็นวงกลมเล็กๆ ซ่อนไว้ข้างหลัง)
                            Container(
                              width: 60, 
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.25), 
                                    blurRadius: 35,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                            // ชั้นที่ 2: รูปภาพสภาพอากาศ (โชว์เต็มใบ ไม่มีการตัดกรอบ)
                            Image.asset(
                              weatherAssetPath, 
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 24),
                        
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              Text(
                                '$temp°',
                                style: TextStyle(
                                  fontSize: 64, 
                                  fontWeight: FontWeight.bold,
                                  color: _primaryTextColor,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                conditionText,
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w500,
                                  color: _primaryTextColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWeatherDetailItem(Icons.air, '$windKmh km/h'),
                        _buildWeatherDetailItem(Icons.cloud, '$humidity %'),
                        _buildWeatherDetailItem(Icons.wb_sunny, '$uv of 10'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeatherDetailItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: _primaryTextColor, size: 30),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primaryTextColor),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer(Widget child) {
    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildLoadingCard() => _buildLoadingContainer(const CircularProgressIndicator());

  Widget _buildErrorCard(String message) => _buildLoadingContainer(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
}