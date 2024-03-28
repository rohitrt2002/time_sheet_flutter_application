import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectListScreen1 extends StatelessWidget {
  final String userId; // Assuming userId is available
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ProjectListScreen1({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time sheet Project List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('projects')
            .where('allocatedEmployees', arrayContains: userId) // Filter projects assigned to the user
            .snapshots(),
        builder: (context, projectSnapshot) {
          if (projectSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (projectSnapshot.hasError) {
            return Center(
              child: Text('Error: ${projectSnapshot.error}'),
            );
          }
          final projects = projectSnapshot.data!.docs;
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final projectData = projects[index].data() as Map<String, dynamic>;
              final projectName = projectData['projectName'] ?? 'Unnamed Project';
              return ListTile(
                title: Text(projectName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailsScreen(projectName: projectName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;

  ProjectDetailsScreen({required this.projectName});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TextEditingController payTaskController = TextEditingController();
  final TextEditingController withoutPayTaskController = TextEditingController();
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
        print('User data fetched successfully: $userDoc');
        setState(() {
          firstName = userDoc['firstName'] ?? '';
          lastName = userDoc['lastName'] ?? '';
        });
      } else {
        print('No user is currently logged in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Project Name: ${widget.projectName}'),


            SizedBox(height: 20),
            TextField(
              controller: payTaskController,
              decoration: InputDecoration(
                labelText: 'Pay Task',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: withoutPayTaskController,
              decoration: InputDecoration(
                labelText: 'Without Pay Task',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProjectDetails(widget.projectName, payTaskController.text, withoutPayTaskController.text);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProjectDetails(String projectName, String payTask, String withoutPayTask) {
    FirebaseFirestore.instance.collection('project_details').add({
      'projectName': projectName,
      'firstName': firstName,
      'lastName': lastName,
      'payTask': payTask,
      'withoutPayTask': withoutPayTask,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project details saved successfully')),
      );
      payTaskController.clear();
      withoutPayTaskController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save project details')),
      );
      print('Error saving project details: $error');
    });
  }
}