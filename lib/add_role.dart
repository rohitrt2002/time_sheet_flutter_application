import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoleScreen extends StatefulWidget {
  @override
  _AddRoleScreenState createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _projectNameController;

  String? _selectedEmployee;
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
            Text('Select Employee:'),
            SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('employees').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final employees = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: _selectedEmployee,
                  hint: Text('Select Employee'),
                  onChanged: (selectedEmployee) {
                    setState(() {
                      _selectedEmployee = selectedEmployee;
                    });
                  },
                  items: employees.map<DropdownMenuItem<String>>((employee) {
                    final employeeData = employee.data() as Map<String, dynamic>;
                    final employeeName = '${employeeData['firstName']} ${employeeData['lastName']}';
                    return DropdownMenuItem<String>(
                      value: employee.id,
                      child: Text(employeeName),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16),
            Text('Select Role:'),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              hint: Text('Select Role'),
              onChanged: (selectedRole) {
                setState(() {
                  _selectedRole = selectedRole;
                });
              },
              items: _roles.map<DropdownMenuItem<String>>((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addRole();
              },
              child: Text('Assign Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _addRole() async {
    if (_selectedEmployee != null && _selectedRole != null) {
      try {
        // Add role to the selected employee
        await _firestore.collection('employees').doc(_selectedEmployee).update({
          'role': _selectedRole,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role assigned successfully')),
        );
      } catch (e) {
        print('Error assigning role: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign role')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an employee and a role')),
      );
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }
}
