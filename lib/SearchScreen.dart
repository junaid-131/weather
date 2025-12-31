import 'package:flutter/material.dart';
import 'package:my_weather_app/weather_service.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  Map<String, dynamic>? data;

  void search() async {
    final result =
    await WeatherService.getByCity(controller.text);
    setState(() => data = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Weather",
            style: TextStyle(color: Colors.white)),
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
                hintText: "Search for a city",
                hintStyle:
                const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                prefixIcon:
                const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (data != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B25A1), Color(0xFF3C2F9C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text("${data!["main"]["temp"].round()}°",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "H:${data!["main"]["temp_max"].round()}°  L:${data!["main"]["temp_min"].round()}°",
                              style: const TextStyle(
                                  color: Colors.white70)),
                          Text(data!["name"],
                              style: const TextStyle(
                                  color: Colors.white)),
                          Text(data!["weather"][0]["main"],
                              style: const TextStyle(
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.cloud,
                        color: Colors.white, size: 50),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
