import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_sheet_flutter_application/User_panel.dart';
import 'package:time_sheet_flutter_application/admin_panel.dart';

class LoginDemo extends StatefulWidget {
  @override
  _LoginDemoState createState() => _LoginDemoState();
}
class _LoginDemoState extends State<LoginDemo> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedInAndRedirect();
  }

  Future<void> _checkLoggedInAndRedirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    if (email != null && password != null) {
      UserCredential? userCredential = await _signInWithEmailAndPassword(email, password);
      if (userCredential != null) {
        if (isAdmin(email)) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserPanel(userId: userCredential.user!.uid),
            ),
          );
        }
      }
    }
  }

  Future<UserCredential?> _signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', email);
      prefs.setString('password', password);
      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  bool isAdmin(String email) {
    const List<String> adminEmails = ['rohitrthakur72@gmail.com', 'admin@gmail.com'];
    return adminEmails.contains(email);
  }

  Future<void> _signOut() async {
    FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
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
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 70),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter valid email id as abc@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.lightBlue.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.blue.withOpacity(0.1),
                  filled: true,
                  prefixIcon: const Icon(Icons.password),
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
                onPressed: () {
                  _signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text);
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(vertical: 8)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
