import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId; // User ID

  ProjectListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project List'),
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
              // You can display more details about the project if needed
              return ListTile(
                title: Text(projectName),
                // Add more ListTile properties as needed
              );
            },
          );
        },
      ),
    );
  }
}
