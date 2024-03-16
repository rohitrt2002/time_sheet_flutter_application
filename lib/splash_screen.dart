import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_sheet_flutter_application/login_screen.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the main application screen after a certain duration
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginDemo(), // Remove'const' from here
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Your splash screen logo widget
        child: Image.asset(
            'assets/image/icons8-flutter-192(-xxxhdpi).png'), // Replace with your splash screen logo asset
      ),
    );
  }
}
