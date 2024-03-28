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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
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
        ],
      ),
    );
  }

  void _assignRoles() async {
    try {
      await _firestore.collection('role').add({
        'role_type': _roleController.text,
        'allocatedEmployees': _selectedEmployees,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role added successfully')),
      );
      // Navigate to a different screen here

    } catch (e) {
      print('Error adding Role type: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Role type')),
      );
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }
}

class RoleDataScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('role').snapshots(),
        builder: (context, teamSnapshot) {
          if (!teamSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final teams = teamSnapshot.data!.docs;
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final teamData = teams[index].data() as Map<String, dynamic>;
              final teamName = teamData['role_type'] ?? 'Unnamed Team';
              return _buildTeamTile(context, teamName, teams[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, String teamName, String teamId) {
    return ExpansionTile(
      title: Text(teamName),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('Role Type')
              .where('role_type', isEqualTo: teamName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final teamDocs = snapshot.data!.docs;
            if (teamDocs.isEmpty) {
              return SizedBox();
            }
            final teamData = teamDocs.first.data() as Map<String, dynamic>;
            final members = teamData['members'] as List<dynamic>;
            return Column(
              children: members.map<Widget>((memberId) {
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('employees').doc(memberId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return SizedBox();
                    }
                    final employeeData = snapshot.data!.data() as Map<String, dynamic>;
                    final employeeName = '${employeeData['firstName']} ${employeeData['lastName']}';
                    return ListTile(
                      title: Text(employeeName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Delete the role
                              _deleteRole(teamId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _deleteRole(String roleId) async {
    try {
      await _firestore.collection('role').doc(roleId).delete();
    } catch (error) {
      print('Error deleting role: $error');
      // Handle error as needed
    }
  }
}
