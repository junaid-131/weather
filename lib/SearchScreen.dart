import 'package:flutter/material.dart';
import 'weather_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  Map<String, dynamic>? weather;
  Map<String, dynamic>? air;
  String city = "";
  bool loading = false;
  String? error;

  void search() async {
    if (controller.text.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final coordinates =
      await WeatherService.getCityCoordinates(controller.text);
      city = controller.text;
      weather = await WeatherService.getWeather(
          coordinates["lat"]!, coordinates["lon"]!);
      air = await WeatherService.getAirQuality(
          coordinates["lat"]!, coordinates["lon"]!);

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Failed to load data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Search Weather", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: (_) => search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter city name",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (error != null)
              Text(error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
            if (weather != null && air != null)
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2B25A1), Color(0xFF3C2F9C)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(city,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 28)),
                          const SizedBox(height: 8),
                          Text(
                              "${weather!["current"]["main"]["temp"].round()}°",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "H:${weather!["daily"][0]["main"]["temp_max"].round()}°  L:${weather!["daily"][0]["main"]["temp_min"].round()}°",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          Text(weather!["current"]["weather"][0]["main"],
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 18)),
                          const SizedBox(height: 12),
                          Text(
                              "AQI: ${air!["list"][0]["main"]["aqi"]}",
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
