import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_sheet_flutter_application/User_panel.dart';
import 'package:time_sheet_flutter_application/admin_panel.dart';
import 'package:time_sheet_flutter_application/splash_screen.dart';

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<LoginDemo> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      print('Email: $email, Password: $password');

      if (email.isEmpty || password.isEmpty) {
        print('Email or password is empty');
        return;
      }

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      if (userCredential != null && userCredential.user != null) {
        print('User signed in successfully: ${userCredential.user!.uid}');

        // Check the user's role and navigate accordingly
        if (isAdmin(email)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPanel(userId: userCredential.user!.uid), // Pass the user ID here
            ),

          );
        }
      } else {
        print('User credential does not contain a valid user');
        // Handle the scenario where the user is null
      }
    } catch (e) {
      print('Error signing in: $e');
      // Handle the error, show a snackbar, or perform other actions
    }
  }

  bool isAdmin(String email) {
    // Implement your logic to determine if the user is an admin
    // For example, you can check if the user's email matches the admin email
    // Return true if the user is an admin, false otherwise
    // Here's a simple example:
    const List<String> adminEmails = ['rohitrthakur72@gmail.com','admin@gmail.com']; // Replace with your admin email(s)
    return adminEmails.contains(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  child: Image.asset(
                    'assets/image/icons8-flutter-192(-xxxhdpi).png',
                    fit: BoxFit.cover, // Use BoxFit.cover to fill the container
                  ),
                ),
              ),
            ),
            SizedBox(height: 70),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText:
                      'Email', // Label text displayed above the input field
                  hintText: 'Enter valid email id as abc@gmail.com',
                  // Hint text displayed inside the input field
                  border: OutlineInputBorder(
                    // Defines the border properties
                    borderRadius: BorderRadius.circular(
                        18), // Sets the border radius to create rounded corners
                    borderSide: BorderSide.none, // Hides the border line
                  ),
                  fillColor: Colors.lightBlue.withOpacity(
                      0.1), // Sets the fill color of the input field with opacity
                  filled:
                      true, // Specifies that the input field should be filled with color
                  prefixIcon: const Icon(Icons
                      .person), // Icon displayed at the beginning of the input field
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _passwordController,
                obscureText:
                    true, // Indicates that the text entered in the field should be obscured (hidden)
                decoration: InputDecoration(
                  labelText:
                      'Password', // Label text displayed above the input field
                  hintText:
                      'Enter secure password', // Hint text displayed inside the input field
                  border: OutlineInputBorder(
                    // Defines the border properties
                    borderRadius: BorderRadius.circular(
                        18), // Sets the border radius to create rounded corners
                    borderSide: BorderSide.none, // Hides the border line
                  ),
                  fillColor: Colors.blue.withOpacity(
                      0.1), // Sets the fill color of the input field with opacity
                  filled:
                      true, // Specifies that the input field should be filled with color
                  prefixIcon: const Icon(Icons
                      .password), // Icon displayed at the beginning of the input field
                ),
              ),
            ),
            SizedBox(height: 80),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: _signInWithEmailAndPassword,
                child: Text(
                  'Login', // Text displayed on the button
                  style: TextStyle(
                    // Use TextStyle instead of ButtonStyle
                    // Define text style properties here
                    fontSize: 23, // Example font size
                    fontWeight: FontWeight.bold, // Example font weight
                    color: Colors.white, // Example text color
                  ),
                ),
                style: ButtonStyle(
                  // Apply button style properties here if needed
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blueAccent), // Example background color
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 8)), // Example padding
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      StadiumBorder()), // Example shape
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
