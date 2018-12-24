import 'package:flutter/material.dart';

import "./home.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: const MaterialColor(
          0xFF000000,
          const <int, Color>{
            50: const Color(0xFF000000),
            100: const Color(0xFF000000),
            200: const Color(0xFF000000),
            300: const Color(0xFF000000),
            400: const Color(0xFF000000),
            500: const Color(0xFF000000),
            600: const Color(0xFF000000),
            700: const Color(0xFF000000),
            800: const Color(0xFF000000),
            900: const Color(0xFF000000),
          }
        ),
        fontFamily: "NYTFranklin",
      ),
      home: Home(),
    );
  }
}