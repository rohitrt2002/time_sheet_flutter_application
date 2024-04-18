import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  void _addEmployee(String firstName, String lastName, String email, String role, String team, String joiningDate, String empId, String mobile, String password) async {
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
        'team': team,
        'joiningDate': joiningDate,
        'empId': empId,
        'mobile': mobile,
        'Password': password,
        // Add more fields as needed
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee added successfully')),
      );
      // Fetch updated employee list
      _fetchEmployees();
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
      ),backgroundColor: Colors.grey ,
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
                color: Colors.white  , // Border color
                width: 1, // Border width
              ),
              color: Colors.blueGrey  ,
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

class AddEmployeeForm extends StatefulWidget {
  final Function(String, String, String, String, String, String, String, String, String) addEmployee;

  AddEmployeeForm({required this.addEmployee});

  @override
  _AddEmployeeFormState createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedRole;
  String? _selectedTeam;
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDate;
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<String>> _fetchRolesFuture;
  late Future<List<String>> _fetchTeamsFuture;

  @override
  void initState() {
    super.initState();
    _fetchRolesFuture = _fetchRoles();
    _fetchTeamsFuture = _fetchTeams(); // Initialize _fetchTeamsFuture here
  }

  Future<List<String>> _fetchRoles() async {
    final firestoreService = FirestoreService();
    final rolesSnapshot = await firestoreService.getRoles().first;
    return rolesSnapshot;
  }

  Future<List<String>> _fetchTeams() async {
    final firestoreService = FirestoreService();
    final teamsSnapshot = await firestoreService.getTeams().first; // Fix typo here
    return teamsSnapshot;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ADD Employee'),
          backgroundColor: Colors.blue,
        ),
        body: Form (
          key: _formKey,
          child: ListView(
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
                ),validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter First Name';
                }
                return null;
              },
              ),
                  // Add other form fields here
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
                  ),validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Last Name';
                }
                return null;
              },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

                  FutureBuilder<List<String>>(
                    future: _fetchRolesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading indicator while fetching roles
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final roles = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedRole,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
                            ),
                            border: OutlineInputBorder(borderSide: BorderSide()),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.engineering_outlined),
                            hintText: 'Select Role Type',
                            labelText: 'Role Type',
                          ),
                          items: roles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select role';
                            }
                            return null;
                          },
                        );
                      }
                    },
                  ),

              SizedBox(height: 16),
                  FutureBuilder<List<String>>(
                    future: _fetchTeamsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading indicator while fetching roles
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final roles = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedTeam,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTeam = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
                            ),
                            border: OutlineInputBorder(borderSide: BorderSide()),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.group),
                            hintText: 'Select Team Type',
                            labelText: 'Team Type',
                          ),
                          items: roles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select team';
                            }
                            return null;
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueGrey, // Adjust border color as needed
                        width: 2.0, // Adjust border width as needed
                      ),
                      borderRadius: BorderRadius.circular(5), // Adjust border radius as needed
                    ),
                    child: TextButton(
                      onPressed: () {
                        _selectDate(context); // Call a method to show date picker
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today , color: Colors.black54    ),
                          SizedBox(width: 10),
                          Text(
                            _selectedDate == null
                                ? 'Select Joining Date'
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            style: TextStyle(
                              color: Colors.black54 , // Adjust text color as needed
                              fontSize: 16, // Adjust font size as needed
                            ),
                          ),
                        ],
                      ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Email';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Mobile Number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey, width: 2.0),
                      ),
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(Icons.password_outlined),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: _isPasswordVisible ? Colors.blue : Colors.grey,
                        ),
                      ),
                      hintText: 'Enter Password',
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
              SizedBox(height: 16),
              Center(
                child: Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
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
                ],),
        )
    );
  }
  void _submitForm() {
    // Access _addEmployee method from the state of AddEmployeeForm
    widget.addEmployee(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      _selectedRole ?? '',
      _selectedTeam ?? '',
      _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      _empIdController.text,
      _mobileController.text,
      _passwordController.text,
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
    // Add validation logic here
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a date'),
      ));
    }}
}
class FirestoreService {
  final CollectionReference rolesCollection =
  FirebaseFirestore.instance.collection('roles');
  final CollectionReference teamsCollection =
  FirebaseFirestore.instance.collection('teams');

  Future<void> addRole(String roleName) async {
    try {
      await rolesCollection.add({'name': roleName});
    } catch (e) {
      print('Error adding role: $e');
    }
  }
  Future<void> addTeam(String teamName) async {
    try {
      await teamsCollection.add({'name': teamName});
    } catch (e) {
      print('Error adding team: $e');
    }
  }

  Stream<List<String>> getRoles() {
    return rolesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
  Stream<List<String>> getTeams() {
    return teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
}
