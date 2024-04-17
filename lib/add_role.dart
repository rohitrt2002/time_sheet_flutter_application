import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet_flutter_application/Dashboard_Screen.dart';

class AddRoleScreen extends StatefulWidget {
  @override
  _AddRoleScreenState createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  List<String> _roles = []; // List to store roles
  String? _selectedRole;
  final FirestoreService _firestoreService = FirestoreService(); // Initialize FirestoreService

  @override
  void initState() {
    super.initState();
    // Fetch roles from Firestore and update the _roles list
    _fetchRoles();
  }

  // Function to fetch roles from Firestore
  void _fetchRoles() {
    _firestoreService.getRoles().listen((roles) {
      setState(() {
        _roles = roles;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role:'),
        backgroundColor: Colors.white54,
      ),
      backgroundColor: Colors.grey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 1, // Border width
                    ),
                    borderRadius: BorderRadius.circular(10), // Border radius
                    color: Colors.blueGrey,
                  ),
                  padding: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(role),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedRole = role;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEmployeeScreen(selectedRole: role),
                                ),
                              );// Add your logic here for adding employees to this role
                            },
                            icon: Icon(Icons.person_add, color: Colors.white),
                            label: Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedRole = role;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewEmployeeScreen(selectedRole: role),
                                ),
                              );// Add your logic here for viewing employees of this role
                            },
                            icon: Icon(Icons.visibility, color: Colors.white),
                            label: Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the screen where you can add a new role
          final newRole = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (context) => AddNewRoleScreen()),
          );

          if (newRole != null && newRole.isNotEmpty) {
            // Add the new role to the list
            setState(() {
              _roles.add(newRole);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
  /*@override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }
}*/



class AddEmployeeScreen extends StatefulWidget {
  final String selectedRole;

  const AddEmployeeScreen({required this.selectedRole});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> _employees;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _selectedRole;
  List<DocumentSnapshot> _selectedEmployees = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _selectedRole = widget.selectedRole;
    _employees = [];

    // Fetch all employees from Firestore
    _fetchEmployees();
  }

  // Function to fetch all employees from Firestore
  void _fetchEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('employees').get();
      setState(() {
        _employees = snapshot.docs;
      });
    } catch (error) {
      print('Error fetching employees: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Employee to ${widget.selectedRole}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Employees:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  final employeeData = employee.data() as Map<String, dynamic>;
                  final firstName = employeeData['firstName'];
                  final lastName = employeeData['lastName'];
                  return CheckboxListTile(
                    title: Text('$firstName $lastName'),
                    value: _selectedEmployees.contains(employee),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked!) {
                          _selectedEmployees.add(employee);
                        } else {
                          _selectedEmployees.remove(employee);
                        }
                      });
                    },
                  );
                },
              ),


            ),

            Center(
              child: ElevatedButton(
                onPressed: _assignRoleToEmployees,
                child: Text('Assign Role'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _assignRoleToEmployees() {
    if (_selectedEmployees.isNotEmpty && _selectedRole != null) {
      List<String> employeeIds = _selectedEmployees.map((e) => e.id).toList();

      // Update the role for selected employees in Firestore
      for (String employeeId in employeeIds) {
        _firestore.collection('employees').doc(employeeId).update({
          'role': _selectedRole!,
        }).then((_) {
          print('Role assigned to employee with ID: $employeeId');
        }).catchError((error) {
          print('Error assigning role: $error');
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Roles assigned to selected employees')),
      );

      // Clear the selected employees
      setState(() {
        _selectedEmployees.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one employee')),
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



class ViewEmployeeScreen extends StatefulWidget {
  final String selectedRole;

  const ViewEmployeeScreen({required this.selectedRole});

  @override
  _ViewEmployeeScreenState createState() => _ViewEmployeeScreenState();
}

class _ViewEmployeeScreenState extends State<ViewEmployeeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Employees for ${widget.selectedRole}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('employees').where('role', isEqualTo: widget.selectedRole).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No employees found for ${widget.selectedRole}'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final employee = snapshot.data!.docs[index];
              final employeeData = employee.data() as Map<String, dynamic>;
              final firstName = employeeData['firstName'];
              final lastName = employeeData['lastName'];
              return ListTile(
                title: Text('$firstName $lastName'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteEmployee(employee.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteEmployee(String employeeId) {
    _firestore.collection('employees').doc(employeeId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee deleted successfully')),
      );
    }).catchError((error) {
      print('Error deleting employee: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee')),
      );
    });
  }
}

class AddNewRoleScreen extends StatefulWidget {
  @override
  _AddNewRoleScreenState createState() => _AddNewRoleScreenState();
}

class _AddNewRoleScreenState extends State<AddNewRoleScreen> {
  TextEditingController _roleController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Role Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String newRole = _roleController.text.trim();
                  if (newRole.isNotEmpty) {
                    await _firestoreService.addRole(newRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New role added successfully'),
                      ),
                    );
                  }
                },
                child: Text('Add Role'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirestoreService {
  final CollectionReference rolesCollection =
  FirebaseFirestore.instance.collection('roles');

  Future<void> addRole(String roleName) async {
    try {
      await rolesCollection.add({'name': roleName});
    } catch (e) {
      print('Error adding role: $e');
    }
  }

  Stream<List<String>> getRoles() {
    return rolesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
}
