// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:teamproject2/provider/current_location_provider.dart';
// import 'package:teamproject2/services/api_service.dart';

// class Weather_widget extends ConsumerStatefulWidget {
//   const Weather_widget({super.key});

//   @override
//   ConsumerState<Weather_widget> createState() =>
//       _Weather_widget();
// }

// final locationProvider = ChangeNotifierProvider((ref) => CurrentLocationProvider());

// class  _Weather_widget extends ConsumerState<Weather_widget> {
//   final _weatherService = WeatherApiService();
//   String city = "Surkhet"; // initially
//   String country = '';
//   Map<String, dynamic> currentValue = {};
//   List<dynamic> hourly = [];
//   List<dynamic> pastWeek = [];
//   List<dynamic> next7days = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _initWeatherLoad();
//   }

//   Future<void> _initWeatherLoad() async {
//       final locationData = ref.read(locationProvider); 

//       if (locationData.isLoading) {
//         // รอจนกว่าจะโหลดตำแหน่งเสร็จ (หรือเช็คสถานะใน build ก็ได้)
//       }

//       _fetchWeather(locationData.currentLocation.latitude, locationData.currentLocation.longitude);
//     }

//   Future<void> _fetchWeather(double lat, double lon) async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       final forecast = await _weatherService.getHourlyForecast(lat, lon);
//       final past = await _weatherService.getPastSevenDaysWeather(lat, lon);

//       setState(() {
//         currentValue = forecast['current'] ?? {};
//         hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
//         pastWeek = past;
//         city = forecast['location']?['name'] ?? city;
//         country = forecast['location']?['country'] ?? '';
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         currentValue = {};
//         hourly = [];
//         pastWeek = [];
//         next7days = [];
//         isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "City not found or invalid. Please enter a valid city name.",
//           ),
//         ),
//       );
//     }
//   }

//   // เติมส่วน build เพื่อให้คลาสสมบูรณ์
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }

