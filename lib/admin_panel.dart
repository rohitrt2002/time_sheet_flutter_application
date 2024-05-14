import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_sheet_flutter_application/Dashboard_Screen.dart';
import 'package:time_sheet_flutter_application/Employee_data.dart';
import 'package:time_sheet_flutter_application/add_role.dart';
import 'package:time_sheet_flutter_application/login_screen.dart';
import 'package:time_sheet_flutter_application/project_data.dart';
import 'package:time_sheet_flutter_application/team.dart';
import 'package:time_sheet_flutter_application/timesheetpaneladmin.dart';

class AdminPanel extends StatefulWidget {
  AdminPanel({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
      DashboardScreen(),
      EmployeeList(),
      ProjectList(),
      AddRoleScreen(),
      AddTeamScreen(),
      timesheetPanelScreen(),


    ];
    return GestureDetector(
        onTap: () {
      Scaffold.of(context).openDrawer();
    },
    child: Scaffold(
      appBar: AppBar(title: const Text("Admin Panel",style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF344955),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
         /* IconButton(
            icon: Icon(Icons.exit_to_app,color: Colors.white,), // Use any icon you prefer for the profile
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
          ),*/
    ],),

      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Container(

        child: Drawer(

          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF344955),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/image/icons8-flutter-192(-xxxhdpi).png',
                      height: 100,
                      width: 80,
                    ),
                  ],
                ),
              ),
              ListTile(
                  title:Row(
                    children: [
                      Icon(Icons.dashboard,color: Colors.black,), // Add icon here
                      SizedBox(width: 10),
                      const Text('Dashboard'),
                    ],
                  ),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(0);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.person,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('Employee'),
                  ],
                ),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(1);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.assignment,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('Project'),
                  ],
                ),
                selected: _selectedIndex == 2,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(2);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.work,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('Role'),
                  ],
                ),
                selected: _selectedIndex == 3,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(3);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.group,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('Team'),
                  ],
                ),
                selected: _selectedIndex == 4,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(4);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.timelapse,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('Teamsheets'),
                  ],
                ),
                selected: _selectedIndex == 5,
                  onTap: () {
                    // Update the state of the app
                    _onItemTapped(5);
                    // Then close the drawer
                    Navigator.pop(context);
                  }
              ),

              IconButton(
                icon: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.logout ,color: Colors.black,),
                    SizedBox(width: 10),
                    const Text('logout',style: TextStyle(color: Colors.black,fontSize:18),)
                  ],
                ), // Use any icon you prefer for the profile
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

      ),
    )));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

