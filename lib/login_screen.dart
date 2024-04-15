import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
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
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    if (email != null && password != null) {
      _signInWithEmailAndPassword(email, password);
    }
  }

  Future<void> _signInWithEmailAndPassword(
      String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);
        prefs.setString('password', password);

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
    } catch (e) {
      print('Error signing in: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error message to the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Error'),
          content: Text(
              'Invalid credentials. Please check your email and password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool isAdmin(String email) {
    const List<String> adminEmails = [
      'rohitrthakur72@gmail.com',
      'admin@gmail.com'
    ];
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
        backgroundColor: Colors.white,
        title: Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange[800] ?? Colors.orange,
                Colors.orange[700] ?? Colors.orange,
                Colors.orange[400] ?? Colors.orange,
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/image/icons8-flutter-192(-xxxhdpi).png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                height: 590,

                decoration: BoxDecoration(

                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
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
                            fillColor: Colors.orangeAccent.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Adjust the spacing as needed
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter secure password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.orangeAccent.withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.password),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 90), // Adjust the spacing as needed
                      _isLoading
                          ? CircularProgressIndicator()
                          : Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (_emailController.text.trim().isEmpty ||
                                _passwordController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text(
                                      'Please enter both email and password.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              _signInWithEmailAndPassword(
                                  _emailController.text.trim(),
                                  _passwordController.text);
                            }
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
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                Colors.orangeAccent),
                            padding: MaterialStateProperty.all<
                                EdgeInsetsGeometry>(
                                EdgeInsets.symmetric(vertical: 8)),
                            shape: MaterialStateProperty.all<
                                OutlinedBorder>(StadiumBorder()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );




  }
}
