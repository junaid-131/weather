import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "4d4a073c34117ee70e51292202ede852";

  /// Get city name from lat/lon
  static Future<String> getCity(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) return data[0]["name"];
    }
    throw Exception("City API error");
  }

  /// Get coordinates from city name
  static Future<Map<String, double>> getCityCoordinates(String city) async {
    final url =
        "https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isEmpty) throw Exception("City not found");
      return {"lat": data[0]["lat"], "lon": data[0]["lon"]};
    }
    throw Exception("Geo API error");
  }

  /// Get weather (current + forecast)
  static Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final currentUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey";
    final forecastUrl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey";

    final currentResp = await http.get(Uri.parse(currentUrl));
    final forecastResp = await http.get(Uri.parse(forecastUrl));

    if (currentResp.statusCode == 200 && forecastResp.statusCode == 200) {
      final currentData = jsonDecode(currentResp.body);
      final forecastData = jsonDecode(forecastResp.body);

      // Merge current + forecast
      return {
        "current": currentData,
        "hourly": forecastData["list"], // 3h interval forecast
        "daily": List.generate(5, (i) => forecastData["list"][i * 8]), // approx daily
      };
    }
    throw Exception("Failed to load weather data");
  }

  /// Get air quality
  static Future<Map<String, dynamic>> getAirQuality(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Air Quality API error");
  }
}
