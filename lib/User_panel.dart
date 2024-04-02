import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_sheet_flutter_application/login_screen.dart';
import 'package:time_sheet_flutter_application/project_list_user.dart';
import 'package:time_sheet_flutter_application/time_sheet_user.dart';

class UserPanel extends StatefulWidget {
  final String userId;

  const UserPanel({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  int _selectedIndex = 0;
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
        print('User data fetched successfully: $userDoc');
        setState(() {
          firstName = userDoc['firstName'] ?? '';
          lastName = userDoc['lastName'] ?? '';
        });
      } else {
        print('No user is currently logged in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
    ProjectListScreen(userId: widget.userId),
      ProjectListScreen1(userId: widget.userId),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("User Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Use any icon you prefer for the profile
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.remove('email');
                  prefs.remove('password');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginDemo(), // Replace 'YourLoginPage()' with the actual constructor of your login page
                    ),
                  );
                } catch (e) {
                  print('Error signing out: $e');
                  // Handle error if necessary
                }
              },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$firstName $lastName'),
                  Image.asset(
                    'assets/image/icons8-flutter-192(-xxxhdpi).png',
                    height: 100,
                    width: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Project List'),
              selected: _selectedIndex == 0,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(0);
                  // Then close the drawer
                  Navigator.pop(context);
                }
            ),
            ListTile(
              title: const Text('Time sheet List'),
              selected: _selectedIndex == 1,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(1);
                  // Then close the drawer
                  Navigator.pop(context);
                }
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
