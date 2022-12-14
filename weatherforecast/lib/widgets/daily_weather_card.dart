import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard(
      {Key? key,
      required this.temperature,
      required this.icon,
      required this.date})
      : super(key: key);

  final String icon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    String weekday = weekdays[DateTime.parse(date).weekday - 1];

    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 120,
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.network('http://openweathermap.org/img/wn/$icon@2x.png'),
              Text(
                '$temperature°C',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(weekday),
            ],
          ),
        ),
      ),
    );
  }
}
