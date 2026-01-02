import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SearchScreen.dart';
import 'weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  String? error;

  Map<String, dynamic>? currentLocationCity;
  List<Map<String, dynamic>> cities = [];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          error = "Location permission denied";
          loading = false;
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final cityName =
      await WeatherService.getCity(pos.latitude, pos.longitude);
      final weather =
      await WeatherService.getWeather(pos.latitude, pos.longitude);
      final air = await WeatherService.getAirQuality(pos.latitude, pos.longitude);

      currentLocationCity = {
        "city": cityName,
        "weather": weather,
        "air": air,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList("cities") ?? [];
      List<Map<String, dynamic>> savedCities =
      list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();

      setState(() {
        cities = [currentLocationCity!, ...savedCities];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load weather data";
        loading = false;
      });
    }
  }

  Future<void> saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = cities.skip(1).toList();
    prefs.setStringList(
        "cities", toSave.map((e) => jsonEncode(e)).toList());
  }

  void addCity(Map<String, dynamic> city) {
    if (cities.any((c) => c["city"] == city["city"])) return;
    setState(() {
      cities.add(city);
    });
    saveCities();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1B33),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || cities.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF1C1B33),
        body: Center(
            child: Text(error ?? "Failed to load data",
                style: const TextStyle(color: Colors.white))),
      );
    }

   /* final current = cities[selectedIndex]["weather"]["current"];
    final hourly = cities[selectedIndex]["weather"]["hourly"];
    final daily = cities[selectedIndex]["weather"]["daily"];
    final air = cities[selectedIndex]["air"];*/

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Weather", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SearchScreen(existingCities: cities)));
              if (result != null) addCity(result);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 250,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount: cities.length,
                        controller: PageController(viewportFraction: 0.95),
                        onPageChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final cityData = cities[index];
                          final w = cityData["weather"]["current"];
                          return topCard(cityData["city"], w);
                        },
                      ),
                    ),
                    if (cities.length > 1)
                      SizedBox(
                        height: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(cities.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: selectedIndex == i ? 12 : 8,
                              height: selectedIndex == i ? 12 : 8,
                              decoration: BoxDecoration(
                                color: selectedIndex == i
                                    ? Colors.white
                                    : Colors.white38,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Draggable scrollable bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              final currentCity = cities[selectedIndex];
              final hourly = currentCity["weather"]["hourly"];
              final daily = currentCity["weather"]["daily"];
              final air = currentCity["air"];
              final current = currentCity["weather"]["current"];
              final wind = current["wind"]["speed"];
              final rain = current["rain"]?["1h"] ?? 0;
              final sunrise = DateFormat.jm().format(
                  DateTime.fromMillisecondsSinceEpoch(current["sys"]["sunrise"] * 1000));
              final sunset = DateFormat.jm().format(
                  DateTime.fromMillisecondsSinceEpoch(current["sys"]["sunset"] * 1000));
              final aqi = air["list"][0]["main"]["aqi"];
              final aqiText = ["Good", "Fair", "Moderate", "Poor", "Very Poor"][aqi - 1];

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B33), // <-- DARK SOLID BACKGROUND
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Hourly Forecast", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 12,
                        itemBuilder: (_, i) {
                          final h = hourly[i];
                          return hourCard(
                            DateTime.fromMillisecondsSinceEpoch(h["dt"] * 1000),
                            h["main"]["temp"].round(),
                            h["weather"][0]["icon"],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("5-Day Forecast", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    ...List.generate(5, (i) {
                      final d = daily[i];
                      return weekRow(
                        DateTime.fromMillisecondsSinceEpoch(d["dt"] * 1000),
                        d["main"]["temp_max"].round(),
                        d["main"]["temp_min"].round(),
                        d["weather"][0]["icon"],
                      );
                    }),
                    const SizedBox(height: 20),
                    infoCard("WIND", "$wind km/h", Icons.air),
                    infoCard("RAIN", "$rain mm", Icons.water_drop),
                    infoCard("SUNRISE", sunrise, Icons.sunny),
                    infoCard("SUNSET", sunset, Icons.nightlight),
                    infoCard("AIR QUALITY", "$aqi - $aqiText", Icons.health_and_safety),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          )

        ],
      ),
    );
  }

  Widget topCard(String city, dynamic weather) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(city,
              style: const TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("${weather["main"]["temp"].round()}°",
              style: const TextStyle(
                  color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
          Text(weather["weather"][0]["description"],
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget hourCard(DateTime time, int temp, String icon) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat.jm().format(time),
              style: const TextStyle(color: Colors.white)),
          Image.network("https://openweathermap.org/img/wn/$icon@2x.png", width: 32),
          Text("$temp°", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget weekRow(DateTime date, int h, int l, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat.E().format(date), style: const TextStyle(color: Colors.white)),
          Image.network("https://openweathermap.org/img/wn/$icon.png", width: 28),
          Text("$h° / $l°", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget infoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient:
        const LinearGradient(colors: [Color(0xFF2E335A), Color(0xFF1C1B33)]),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }
}
