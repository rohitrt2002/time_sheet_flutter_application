import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTeamScreen extends StatefulWidget {
  @override
  _AddTeamScreenState createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _teamNameController = TextEditingController();
  List<String> _selectedEmployees = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Team'),
      ),backgroundColor: Colors.grey,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _teamNameController,
            decoration: InputDecoration(
              labelText: 'Team Name',
            ),
          ),
          SizedBox(height: 16),
          Text('Select Employees for the Team:'),
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
                        } else {
                          _selectedEmployees.remove(employee.id);
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
              _addTeam();
            },
            child: Text('Add Team'),
          ),
        ],
      ),
    );
  }

  void _addTeam() async {
    try {
      await _firestore.collection('teams').add({
        'teamName': _teamNameController.text,
        'members': _selectedEmployees,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team added successfully')),
      );
      // Navigate to a different screen here
    } catch (e) {
      print('Error adding Team: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add Team')),
      );
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }
}

class EmployeeDataScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
        backgroundColor: Colors.grey,
      ),backgroundColor: Colors.grey,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('teams').snapshots(),
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
              final teamName = teamData['teamName'] ?? 'Unnamed Team';
              final teamId = teams[index].id;
              return _buildTeamTile(context, teamName,teamId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddTeamScreen()),

          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTeamTile(BuildContext context, String teamName,String teamId) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white, // Border color
          width: 1, // Border width
        ),
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10), // Border radius
      ),
      padding: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(teamName),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            _deleteTeam(teamId);
          },
        ),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('teams')
                .where('teamName', isEqualTo: teamName)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }
              final team = snapshot.data!.docs.first;
              final teamData = team.data() as Map<String, dynamic>;
              final members = teamData['members'] as List<dynamic>;
              return Column(
                children: members.map<Widget>((memberId) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('employees').doc(memberId).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
                      final employeeData = snapshot.data!.data() as Map<String, dynamic>;
                      final employeeName = '${employeeData['firstName']} ${employeeData['lastName']}';
                      return ListTile(
                        title: Text(employeeName),
                      );
                    },
                  );
                }).toList(),
              );

            },
          ),
        ],

      ),
    );
  }
void _deleteTeam(String teamId) {
  _firestore.collection('teams').doc(teamId).delete();
}
}

