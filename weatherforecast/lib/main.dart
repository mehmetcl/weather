import 'package:flutter/material.dart';
import 'package:weatherforecast/home_page.dart';
import 'home_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hava Durumu',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}
