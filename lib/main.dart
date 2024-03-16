import 'package:flutter/material.dart';
import 'package:time_sheet_flutter_application/splash_screen.dart';


void main() {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
