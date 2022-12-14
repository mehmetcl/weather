import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:weatherforecast/home_page.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final String key = 'd7a23f18766037ae12eb52057adf43a7';
  String selectedCity = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/search.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TextField(
                onChanged: (value) {
                  selectedCity = value;
                },
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Sehir Seciniz:',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            ButtonTheme(
              minWidth: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.brown),
                onPressed: () async {
                  http.Response response = await http.get(Uri.parse(
                      'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=$key&units=metric'));

                  if (response.statusCode == 200) {
                    Navigator.pop(context, selectedCity);
                  } else {
                    _showMyDialog();
                  }
                },
                child: const Text('Şehri seç'),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konum Bulunamadı!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Lütfen geçerli bir konum giriniz..'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
