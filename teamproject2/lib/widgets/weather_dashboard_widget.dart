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
            final iconUrl = "https:${current['condition']['icon']}";
            final windKmh = current['wind_kph'];
            final humidity = current['humidity'];
            final uv = current['uv'];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(iconUrl, width: 90, height: 90, fit: BoxFit.cover),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$temp°',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                                height: 1.0,
                              ),
                            ),
                            Text(
                              conditionText,
                              style: TextStyle(fontSize: 18, color: Colors.blueGrey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetailItem(Icons.air, '${windKmh} km/h', 'ลม'),
                        _buildWeatherDetailItem(Icons.water_drop, '${humidity} %', 'ความชื้น'),
                        _buildWeatherDetailItem(Icons.wb_sunny, '${uv} of 10', 'UV Index'),
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

  Widget _buildWeatherDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey[400], size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.blueGrey[500])),
      ],
    );
  }

  Widget _buildLoadingCard() => const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())));
  Widget _buildErrorCard(String message) => Card(child: Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(message, style: const TextStyle(color: Colors.red)))));
}