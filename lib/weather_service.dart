import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "4d4a073c34117ee70e51292202ede852";
  static const String baseUrl =
      "https://api.openweathermap.org/data/2.5/weather";

  static Future<Map<String, dynamic>> getByLatLon(
      double lat, double lon) async {
    final url =
        "$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Failed to load weather");
  }

  static Future<Map<String, dynamic>> getByCity(String city) async {
    final url =
        "$baseUrl?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("City not found");
  }
}
