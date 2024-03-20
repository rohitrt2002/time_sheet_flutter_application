import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignRolesScreen extends StatefulWidget {
  @override
  _AssignRolesScreenState createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _selectedEmployees = [];
  Map<String, String> _selectedRoles = {};
  TextEditingController _roleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Roles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roleController,
              onChanged: (value) {
                // Update the role for all employees as the user types
                setState(() {
                  _selectedEmployees.forEach((employeeId) {
                    _selectedRoles[employeeId] = value;
                  });
                });
              },
              decoration: InputDecoration(
                labelText: 'Type role ',
              ),
            ),
            SizedBox(height: 16),
            Text('Select Employees:'),
            SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('employees').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final employees = snapshot.data!.docs;
                return Column(
                  children: employees.map<Widget>((employee) {
                    final employeeData =
                    employee.data() as Map<String, dynamic>;
                    final employeeName =
                        '${employeeData['firstName']} ${employeeData['lastName']}';
                    return CheckboxListTile(
                      title: Text(employeeName),
                      value: _selectedEmployees.contains(employee.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedEmployees.add(employee.id);
                            _selectedRoles[employee.id] =
                                _roleController.text; // Assign role immediately when selecting
                          } else {
                            _selectedEmployees.remove(employee.id);
                            _selectedRoles.remove(employee.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _assignRoles();
              },
              child: Text('Assign Roles'),
            ),
          ],
        ),
      ),
    );
  }

  void _assignRoles() async {
    // You can implement the functionality to assign roles to selected employees here
    // For demonstration purposes, let's print the selected employees and their roles
    print('Selected Employees: $_selectedEmployees');
    print('Selected Roles: $_selectedRoles');
    // You can proceed to update Firestore with the assigned roles
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }
}
