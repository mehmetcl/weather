import 'package:flutter/material.dart';
import 'search_page.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'widgets/daily_weather_card.dart';
import 'widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = 'Ankara';
  double? temperature;
  final String key = 'd7a23f18766037ae12eb52057adf43a7';
  var locationData;
  String weatherstate = 'home';
  Position? devicePosition;
  String? icon;

  List<String?> icons = ["01n", "01n", "01n", "01n", "01n", "01n"];
  List<double?> temperatures = [20.0, 20.0, 20.0, 20.0, 20.0];
  List<String?> dates = ["Ptesi", "Sali", "Car", "Per", "Cuma"];

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      weatherstate = locationDataParsed['weather'].first['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=${key}&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        weatherstate = locationDataParsed['weather'].first['main'];
        icon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    try {
      devicePosition = await _determinePosition();
      print('Device Prosition: $devicePosition');
    } catch (error) {
      print(error);
    } finally {}
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));

    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?$location&appid=${key}&units=metric'));
    var forecastDateParsedd = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();
    setState(() {
      for (int i = 7; i < 40; i + 8) {
        temperatures.add(forecastDateParsedd['List'][i]['main']['temp']);
        icons.add(forecastDateParsedd['List'][i]['weather']['0']['icon']);
        dates.add(forecastDateParsedd['List'][i]['dt_txt']);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon();
    await getDailyForecastByLatLon(); //forecast for 5 days
  }

  @override
  void initState() {
    getInitialData();
    //getLocationDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration containerDecoration = BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/$weatherstate.jpg'),
        fit: BoxFit.cover,
      ),
    );
    return Container(
      decoration: containerDecoration,
      child: (temperature == null ||
              devicePosition == null ||
              icons.isEmpty ||
              dates.isEmpty ||
              temperatures.isEmpty)
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Image.network(
                          'http://openweathermap.org/img/wn/$icon@2x.png'),
                    ),
                    Text(
                      '$temperature°C',
                      style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(8, 5))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style:
                              const TextStyle(fontSize: 30, shadows: <Shadow>[
                            Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(
                                  8,
                                  5,
                                ))
                          ]),
                        ),
                        IconButton(
                          onPressed: () async {
                            final selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));
                            location = selectedCity;
                            await getLocationDataFromAPI();
                            await getDailyForecastByLocation();
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                    buildWeatherCards(context)
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          temperature: temperatures[i]!, icon: icons[i]!, date: dates[i]!));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
