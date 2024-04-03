import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoleScreen extends StatefulWidget {
  @override
  _AddRoleScreenState createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _projectNameController;

  String? _selectedRole;

  // Define list of roles
  List<String> _roles = ['PM', 'QA', 'DEV', 'BA', 'Designer', 'Tech Lead'];

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Role:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return ListTile(
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
                              MaterialPageRoute(builder: (context) => AddEmployeeScreen(selectedRole: role)),
                            );
                          },
                          icon: Icon(Icons.person_add),
                          label: Text(''),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedRole = role;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ViewEmployeeScreen(selectedRole: role)),
                            );
                          },
                          icon: Icon(Icons.visibility),
                          label: Text(''),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            ],

        ),
      ),
    );
  }



  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }
}



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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _assignRoleToEmployees,
              child: Text('Assign Role'),
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

