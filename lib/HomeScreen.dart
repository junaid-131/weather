import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_weather_app/weather_service.dart';
import 'SearchScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? weather;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final data =
    await WeatherService.getByLatLon(24.8607, 67.0011);
    setState(() {
      weather = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1C1B33),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final city = weather!["name"];
    final temp = weather!["main"]["temp"].round();
    final high = weather!["main"]["temp_max"].round();
    final low = weather!["main"]["temp_min"].round();
    final condition = weather!["weather"][0]["main"];
    final wind = weather!["wind"]["speed"];
    final rain = weather!["rain"]?["1h"] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                    ),
                  ),
                  Text(city,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28)),
                  Text("$temp°",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 72)),
                  Text(condition,
                      style: const TextStyle(color: Colors.white70)),
                  Text("H:$high°   L:$low°",
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            minChildSize: 0.38,
            initialChildSize: 0.38,
            maxChildSize: 0.88,
            builder: (context, controller) {
              return ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    color: Colors.white.withOpacity(0.12),
                    child: DefaultTabController(
                      length: 2,
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const TabBar(
                            indicatorColor: Colors.white,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white60,
                            tabs: [
                              Tab(text: "Hourly Forecast"),
                              Tab(text: "Weekly Forecast"),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 180,
                            child: TabBarView(
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 8,
                                  itemBuilder: (_, i) =>
                                      hourCard(temp),
                                ),
                                Column(
                                  children: [
                                    weekRow("Mon", high, low),
                                    weekRow("Tue", high, low),
                                    weekRow("Wed", high, low),
                                    weekRow("Thu", high, low),
                                    weekRow("Fri", high, low),
                                    weekRow("Sat", high, low),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          const AirQualityCard(),

                          GridView.count(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: [
                              const InfoCard(
                                  icon: Icons.sunny,
                                  title: "UV INDEX",
                                  value: "4",
                                  subtitle: "Moderate"),
                              const InfoCard(
                                  icon: Icons.sunny_snowing,
                                  title: "SUNRISE",
                                  value: "5:28 AM",
                                  subtitle: "Sunset 7:25 PM"),
                              InfoCard(
                                  icon: Icons.air,
                                  title: "WIND",
                                  value: "$wind km/h",
                                  subtitle: "North"),
                              InfoCard(
                                  icon: Icons.water_drop,
                                  title: "RAIN",
                                  value: "$rain mm",
                                  subtitle: "Last hour"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.transparent,
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 50),
              Icon(Icons.menu, color: Colors.white),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF2E335A)),
        onPressed: () {},
      ),
    );
  }
}

Widget hourCard(int temp) {
  return Container(
    width: 75,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("12 PM", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        const Icon(Icons.cloud, color: Colors.white),
        const SizedBox(height: 6),
        Text("$temp°", style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

Widget weekRow(String day, int h, int l) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(color: Colors.white)),
        const Icon(Icons.cloud, color: Colors.white),
        Text("$h° / $l°", style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

class InfoCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;

  const InfoCard(
      {super.key,
        required this.title,
        required this.value,
        required this.subtitle,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22)),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  @override
  Widget build(BuildContext context) {
    const double sliderValue = 3;
    const String healthRisk = "Low Health Risk";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Air Quality",
                style:
                TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            const Text("$sliderValue - $healthRisk",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Slider(
              value: sliderValue,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}
