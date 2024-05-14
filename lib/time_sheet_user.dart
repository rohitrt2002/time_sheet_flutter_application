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
        title: Text('Time sheet Project List',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF232F34),
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
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white  , // Border color
                    width: 1, // Border width
                  ),
                  color: Color(0xFF4A6572)  ,
                  borderRadius: BorderRadius.circular(10), // Border radius
                ),
                child: ListTile(
                  title: Text(projectName,style: TextStyle(color: Colors.white,fontSize: 20),),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.task,color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsScreen(projectName: projectName),
                            ),
                          );
                        },
                      ),

                    ],
                  ),


                ),
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
        title: Text('Project Details',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF232F34),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 300, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 1, // Border width
                    ),
                    color: Color(0xFF4A6572),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Project Name - ${widget.projectName}',
                      style: TextStyle(color: Colors.white,fontSize: 20), // Adjust the font size as needed
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextField(
                  controller: payTaskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pay Task',
                  ),
                  minLines: 5, // Set the minimum number of lines
                  maxLines: 5, // Set the maximum number of lines to null for unlimited lines
                ),
                SizedBox(height: 20),
                TextField(
                  controller: withoutPayTaskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Without Pay Task',
                  ),
                    minLines: 5, // Set the minimum number of lines
                    maxLines: 5,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Color(0xFF232F34),elevation: 10,),
                  onPressed: () {
                    _saveProjectDetails(widget.projectName, payTaskController.text, withoutPayTaskController.text);
                  },

                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ],
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