import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import 'weather_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? existingCities;

  const SearchScreen({super.key, this.existingCities});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  bool loading = false;
  String? error;
  Map<String, dynamic>? currentResult;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("history") ?? [];
    setState(() {
      history = list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    });
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("history", history.map((e) => jsonEncode(e)).toList());
  }

  Future<void> searchCity(String city) async {
    if (city.isEmpty) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final coords = await WeatherService.getCityCoordinates(city);
      final weather = await WeatherService.getWeather(coords["lat"]!, coords["lon"]!);
      final air = await WeatherService.getAirQuality(coords["lat"]!, coords["lon"]!);

      final item = {
        "city": city,
        "weather": weather,
        "air": air,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      setState(() {
        currentResult = item;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = "Failed to load data";
      });
    }
  }

  void addToHistory(Map<String, dynamic> item) {
    setState(() {
      history.removeWhere((e) => e["city"] == item["city"]);
      history.insert(0, item);
    });
    saveHistory();
  }

  void clearCityHistory(String city) {
    setState(() {
      history.removeWhere((e) => e["city"] == city);
    });
    saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Search Weather", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: searchCity,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter city name",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading) const CircularProgressIndicator(),
            if (error != null) Text(error!, style: const TextStyle(color: Colors.redAccent)),
            if (currentResult != null) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Search Result",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              searchResultCard(currentResult!),
            ],
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Search History",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.white70),
                    title: Text(item["city"], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                        "${item["weather"]["current"]["main"]["temp"].round()}°C",
                        style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => clearCityHistory(item["city"]),
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeatherDetailScreen(
                            data: item,
                            alreadyAdded: widget.existingCities?.any((c) => c["city"] == item["city"]) ?? false,
                          ),
                        ),
                      );
                      if (result != null) Navigator.pop(context, result);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchResultCard(Map<String, dynamic> item) {
    final weather = item["weather"]["current"];
    return GestureDetector(
      onTap: () async {
        addToHistory(item);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherDetailScreen(
              data: item,
              alreadyAdded: widget.existingCities?.any((c) => c["city"] == item["city"]) ?? false,
            ),
          ),
        );
        if (result != null) Navigator.pop(context, result);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2B25A1), Color(0xFF3C2F9C)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item["city"],
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${weather["main"]["temp"].round()}°C",
                style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
            Text(weather["weather"][0]["description"], style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
