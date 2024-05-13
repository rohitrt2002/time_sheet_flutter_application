import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet_flutter_application/Dashboard_Screen.dart';

class AddRoleScreen extends StatefulWidget {
  @override
  _AddRoleScreenState createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  List<String> _roles = []; // List to store roles
  String? _selectedRole;
  final FirestoreService _firestoreService = FirestoreService(); // Initialize FirestoreService

  @override
  void initState() {
    super.initState();

    _fetchRoles();
  }
  FirestoreService firestoreService = FirestoreService();

  Future<void> _deleteRole(String roleName) async {
    try {
      await firestoreService.deleteRole(roleName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete role'),
        ),
      );
    }
  }
  // Function to fetch roles from Firestore
  void _fetchRoles() {
    _firestoreService.getRoles().listen((roles) {
      setState(() {
        _roles = roles;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role:',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF232F34),
      ),
      backgroundColor: Colors.grey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final role = _roles[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 1, // Border width

                    ),
                    borderRadius: BorderRadius.circular(10), // Border radius
                      color: Color(0xFF4A6572),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(role, style: TextStyle(color: Colors.white),),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedRole = role;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditRoleScreen(role: _selectedRole ?? ''),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.white),

                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _deleteRole(role); // Call the _deleteRole method passing the role name
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.white),

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
        backgroundColor: Color(0xFF232F34),
        onPressed: () async {
          // Navigate to the screen where you can add a new role
          final newRole = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (context) => AddNewRoleScreen()),
          );

          if (newRole != null && newRole.isNotEmpty) {
            // Add the new role to the list
            setState(() {
              _roles.add(newRole);
            });
          }
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}



class EditRoleScreen extends StatelessWidget {
  final String role;
  final TextEditingController _controller = TextEditingController();

  EditRoleScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    _controller.text = role;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Role Name: $role'),
            SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'New Role Name'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final newRoleName = _controller.text.trim();
                  if (newRoleName.isNotEmpty) {
                    try {
                      await FirestoreService().updateRole(role, newRoleName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Role name updated successfully'),
                        ),
                      );
                      Navigator.pop(context); // Go back to previous screen
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update role name'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Update Role Name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class AddNewRoleScreen extends StatefulWidget {
  @override
  _AddNewRoleScreenState createState() => _AddNewRoleScreenState();
}

class _AddNewRoleScreenState extends State<AddNewRoleScreen> {
  TextEditingController _roleController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Role',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF232F34),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Role Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF232F34)),),
                onPressed: () async {
                  String newRole = _roleController.text.trim();
                  if (newRole.isNotEmpty) {
                    await _firestoreService.addRole(newRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New role added successfully'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Role',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirestoreService {
  final CollectionReference rolesCollection =
  FirebaseFirestore.instance.collection('roles');

  Future<void> addRole(String roleName) async {
    try {
      await rolesCollection.add({'name': roleName});
    } catch (e) {
      print('Error adding role: $e');
    }
  }

  Stream<List<String>> getRoles() {
    return rolesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
  Future<void> deleteRole(String roleName) async {
    try {
      QuerySnapshot querySnapshot = await rolesCollection
          .where('name', isEqualTo: roleName)
          .get();
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    } catch (e) {
      throw Exception('Error deleting role: $e');
    }
  }
  Future<void> updateRole(String oldRoleName, String newRoleName) async {
    try {
      QuerySnapshot snapshot = await rolesCollection
          .where('name', isEqualTo: oldRoleName)
          .get();

      snapshot.docs.forEach((doc) async {
        await doc.reference.update({'name': newRoleName});
      });
    } catch (e) {
      print('Error updating role: $e');
      throw e; // Optionally, rethrow the exception to handle it in the calling code
    }
  }
}
