import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = "77a47fc4a5fd4b0c882175657261702"; // used your api key

//for hourly forecast
class WeatherApiService {
  final String _baseUrl = "https://api.weatherapi.com/v1";
  Future<Map<String, dynamic>> getHourlyForecast(double lat, double lon) async {
    final url = Uri.parse(
      "$_baseUrl/forecast.json?key=$apiKey&q=$lat,$lon&days=7",
    );

    final res = await http.get(url);
    if(res.statusCode != 200) {
      throw Exception("Failed to fetch data: ${res.body}");
    }
    final data = json.decode(res.body);
    //check if API returned an error (invalid location)
    if(data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

}