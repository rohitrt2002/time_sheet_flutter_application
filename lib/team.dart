import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet_flutter_application/Dashboard_Screen.dart';

class AddTeamScreen extends StatefulWidget {
  @override
  _AddTeamScreenState createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  List<String> _teams = [];
  String? _selectedTeam;
  final FirestoreService _firestoreService = FirestoreService(); // Initialize FirestoreService

  @override
  void initState() {
    super.initState();

    _fetchTeams();
  }
  FirestoreService firestoreService = FirestoreService();

  Future<void> _deleteTeam(String teamName) async {
    try {
      await firestoreService.deleteTeam(teamName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting team: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete team'),
        ),
      );
    }
  }

  void _fetchTeams() {
    _firestoreService.getTeams().listen((teams) {
      setState(() {
        _teams = teams;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Team:'),
        backgroundColor: Colors.white54,
      ),
      backgroundColor: Colors.grey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                final team = _teams[index];
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
                      title: Text(team),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedTeam = team;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTeamScreen(team: _selectedTeam ?? ''),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _deleteTeam(team);
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.white),
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

          final newTeam = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (context) => AddNewTeamScreen()),
          );

          if (newTeam != null && newTeam.isNotEmpty) {

            setState(() {
              _teams.add(newTeam);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}



class EditTeamScreen extends StatelessWidget {
  final String team;
  final TextEditingController _controller = TextEditingController();

  EditTeamScreen({required this.team});

  @override
  Widget build(BuildContext context) {
    _controller.text = team;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Team Name: $team'),
            SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'New Team Name'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final newTeamName = _controller.text.trim();
                  if (newTeamName.isNotEmpty) {
                    try {
                      await FirestoreService().updateTeam(team, newTeamName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Team name updated successfully'),
                        ),
                      );
                      Navigator.pop(context); // Go back to previous screen
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update Team name'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Update Team Name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class AddNewTeamScreen extends StatefulWidget {
  @override
  _AddNewTeamScreenState createState() => _AddNewTeamScreenState();
}

class _AddNewTeamScreenState extends State<AddNewTeamScreen> {
  TextEditingController _teamController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _teamController,
              decoration: InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String newTeam = _teamController.text.trim();
                  if (newTeam.isNotEmpty) {
                    await _firestoreService.addTeam(newTeam);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New team added successfully'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Team'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirestoreService {
  final CollectionReference teamsCollection =
  FirebaseFirestore.instance.collection('teams');

  Future<void> addTeam(String teamName) async {
    try {
      await teamsCollection.add({'name': teamName});
    } catch (e) {
      print('Error adding team: $e');
    }
  }

  Stream<List<String>> getTeams() {
    return teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
  Future<void> deleteTeam(String teamName) async {
    try {
      QuerySnapshot querySnapshot = await teamsCollection
          .where('name', isEqualTo: teamName)
          .get();
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    } catch (e) {
      throw Exception('Error deleting team: $e');
    }
  }
  Future<void> updateTeam(String oldTeamName, String newTeamName) async {
    try {
      QuerySnapshot snapshot = await teamsCollection
          .where('name', isEqualTo: oldTeamName)
          .get();

      snapshot.docs.forEach((doc) async {
        await doc.reference.update({'name': newTeamName});
      });
    } catch (e) {
      print('Error updating team: $e');
      throw e; // Optionally, rethrow the exception to handle it in the calling code
    }
  }
}
