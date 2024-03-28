import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class timesheetPanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Project Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
                return ListView.builder(
                  itemCount: projectData.length,
                  itemBuilder: (context, index) {
                    final project = projectData[index].data() as Map<String, dynamic>;
                    final projectName = project['projectName'] ?? 'Unnamed Project';
                    final firstName = project['firstName'] ?? '';
                    final lastName = project['lastName'] ?? '';
                    final payTask = project['payTask'] ?? '';
                    final withoutPayTask = project['withoutPayTask'] ?? '';
                    return ListTile(
                      title: Text(projectName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: $firstName $lastName'),
                          Text('Pay Task: $payTask'),
                          Text('Without Pay Task: $withoutPayTask'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
