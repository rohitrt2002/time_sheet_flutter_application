import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class timesheetPanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details:'),
          backgroundColor: Colors.grey,
      ),backgroundColor: Colors.grey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('project_details').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final projectData = snapshot.data!.docs;

                return Container(
                  color: Colors.blueGrey,
                  child: SingleChildScrollView( // Wrap with SingleChildScrollView
                    scrollDirection: Axis.horizontal,

                    // Allow horizontal scrolling
                    child: DataTable(

                      columns: [
                        DataColumn(label: Text('Project Name')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Pay Task')),
                        DataColumn(label: Text('Without Pay Task')),
                      ],
                      rows: projectData.map((doc) {
                        final project = doc.data() as Map<String, dynamic>;
                        final projectName = project['projectName'] ?? 'Unnamed Project';
                        final firstName = project['firstName'] ?? '';
                        final lastName = project['lastName'] ?? '';
                        final payTask = project['payTask'] ?? '';
                        final withoutPayTask = project['withoutPayTask'] ?? '';
                        return DataRow(
                          cells: [
                            DataCell(Text(projectName)),
                            DataCell(Text('$firstName $lastName')),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Pay Task Details'),
                                        content: Text(payTask),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Without Pay Task Details'),
                                        content: Text(withoutPayTask),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
