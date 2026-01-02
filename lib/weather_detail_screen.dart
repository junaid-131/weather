import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool alreadyAdded;

  const WeatherDetailScreen({
    super.key,
    required this.data,
    required this.alreadyAdded,
  });

  @override
  Widget build(BuildContext context) {
    final weather = data["weather"]["current"];
    final air = data["air"];
    final city = data["city"];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1B33),
      appBar: AppBar(
        title: Text(city, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: alreadyAdded ? Colors.white38 : Colors.white,
            ),
            onPressed: alreadyAdded
                ? null
                : () {
              // Return this city to previous screen
              Navigator.pop(context, data);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                "${weather["main"]["temp"].round()}°C",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                weather["weather"][0]["description"],
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            detail("Humidity", "${weather["main"]["humidity"]}%"),
            detail("Pressure", "${weather["main"]["pressure"]} hPa"),
            detail("Wind Speed", "${weather["wind"]["speed"]} m/s"),
            detail("AQI", air["list"][0]["main"]["aqi"].toString()),
          ],
        ),
      ),
    );
  }

  Widget detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
