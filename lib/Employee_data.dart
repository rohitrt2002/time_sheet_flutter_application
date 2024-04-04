import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeList extends StatefulWidget {
  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot>? _employees; // Make the list nullable

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('employees').get();
      setState(() {
        _employees = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  void _deleteEmployee(String id) async {
    try {
      await _firestore.collection('employees').doc(id).delete();
      _fetchEmployees();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee deleted successfully')),
      );
    } catch (e) {
      print('Error deleting employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee')),
      );
    }
  }

  void _editEmployee(DocumentSnapshot employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEmployeeScreen(employee: employee),
      ),
    );
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
        backgroundColor: Colors.white54   ,
      ),
      body: _buildEmployeeList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen where you can add a new employee
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEmployeeForm(addEmployee: _addEmployee)),

          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      itemCount: _employees?.length ?? 0, // Use null-aware operator and null check
      itemBuilder: (context, index) {
        final employee = _employees?[index];
        final data = employee?.data(); // Use null-aware operator
        if (data != null && data is Map<String, dynamic>) {
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          final email = data['email'] as String? ?? '';

          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!, // Border color
                width: 1, // Border width
              ),
              borderRadius: BorderRadius.circular(10), // Border radius
            ),
            padding: EdgeInsets.all(10), // Padding inside the container
            child: ListTile(
              title: Text(' $firstName $lastName'),
              subtitle: Text(email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editEmployee(employee!);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteEmployee(employee!.id);
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox(); // Return an empty widget if data is not valid
        }
      },
    );
  }
}

class EditEmployeeScreen extends StatefulWidget {
  final DocumentSnapshot employee;

  const EditEmployeeScreen({required this.employee});

  @override
  _EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.employee['firstName']);
    _lastNameController =
        TextEditingController(text: widget.employee['lastName']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    try {
      await widget.employee.reference.update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee details updated successfully')),
      );
    } catch (e) {
      print('Error updating employee details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee details')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
    return Scaffold(
        appBar: AppBar(
          title: Text('ADD Employee'),
          backgroundColor: Colors.blue  ,
        ),
      body:ListView(
        padding: const EdgeInsets.all(8.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.account_box_outlined),
                hintText: 'Enter First Name',
                labelText: 'First Name',
              ),
            ), // Add other form fields here
            SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.account_tree_outlined ),
                  hintText: 'Enter Last Name',
                  labelText: 'Last Name',
                ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.email_outlined ),
                hintText: 'Enter Emails ID',
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.engineering_outlined),
                hintText: 'Enter Role Type',
                labelText: 'Role Type',
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _joiningDateController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.date_range_outlined ),
                hintText: 'Enter Joining Date',
                labelText: 'Joining Date',
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _empIdController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.perm_identity  ),
                hintText: 'Enter EMP ID',
                labelText: 'Unique ID or EMP Code',
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.phone   ),
                hintText: 'Enter Mobile Number',
                labelText: 'Mobile Number',
              ),
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: _passwordController ,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide:BorderSide(color: Colors.blueGrey, width: 2.0)),
                border: OutlineInputBorder(borderSide: BorderSide()),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.password_outlined ),
                hintText: 'Enter Password',
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Expanded(
                child: ElevatedButton(
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
                      _passwordController.text,
                    );
                  },
                  child: Text(
                    'Add Employee',
                    style: TextStyle(fontSize: 20), // Increase font size
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                    elevation: 10, // Button's elevation when it's pressed
                  ),
                ),
              ),
            ),
          ],
        ),
      ],)
    );
  }
}


