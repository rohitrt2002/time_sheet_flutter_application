import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _addEmployee(String firstName, String lastName, String email, String role, String joiningDate, String empId, String mobile, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String userId = userCredential.user!.uid; // Get the user UID
      await _firestore.collection('employees').doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'joiningDate': joiningDate,
        'empId': empId,
        'mobile': mobile,
        'Password':password ,
        // Add more fields as needed
      });
      // Show success message or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added successfully')),
      );
    } catch (e) {
      print('Error adding employee: $e');
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add employee')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
      EmployeeList(),
      ProjectList(),
      RoleDataScreen(),
      EmployeeDataScreen(),
      timesheetPanelScreen(),
      AddProjectScreen(),
      // Content for Add Employee
      AddEmployeeForm(addEmployee: _addEmployee),
      AssignRolesScreen(),
      AddTeamScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), // Use any icon you prefer for the profile
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
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
    ],),

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
                  Image.asset(
                    'assets/image/icons8-flutter-192(-xxxhdpi).png',
                    height: 100,
                    width: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Employee'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('Project'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              title: const Text('Role'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              title: const Text('Team'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              title: const Text('Teamsheets'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              title: const Text('Add Project +'),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
            ListTile(
              title: const Text('Add Employee +'),
              selected: _selectedIndex == 6,
              onTap: () => _onItemTapped(6),
            ),
            ListTile(
              title: const Text('Add Role +'),
              selected: _selectedIndex == 7,
              onTap: () => _onItemTapped(7),
            ),
            ListTile(
              title: const Text('Add Team +'),
              selected: _selectedIndex == 8,
              onTap: () => _onItemTapped(8),
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

class AddEmployeeForm extends StatelessWidget {
  final Function(String, String, String, String, String, String, String, String) addEmployee;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AddEmployeeForm({required this.addEmployee});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                hintText: 'Enter First Name',
              ),
            ), // Add other form fields here
            SizedBox(height: 16),
            Text(
              'Last Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                hintText: 'Enter Last Name',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter Email',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Role Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                hintText: 'Enter Role type',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Joining Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _joiningDateController,
              decoration: InputDecoration(
                hintText: 'Enter Joining Date',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Unique ID or EMP Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _empIdController,
              decoration: InputDecoration(
                hintText: 'Enter Unique ID or EMP Code',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Mobile Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                hintText: 'Enter Mobile Number',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: _passwordController ,
              decoration: InputDecoration(
                hintText: 'Enter Password',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Access _addEmployee method from the state of AdminPanel
                addEmployee(
                  _firstNameController.text,
                  _lastNameController.text,
                  _emailController.text,
                  _roleController.text,
                  _joiningDateController.text,
                  _empIdController.text,
                  _mobileController.text,
                  _passwordController.text ,
                );
              },

              child: Text('Add Employee'),
            ),
          ],
        ),
      ],
    );
  }
}
