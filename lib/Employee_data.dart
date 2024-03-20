import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeList extends StatefulWidget {
  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot>? _employees; // Make the list nullable

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('employees').get();
      setState(() {
        _employees = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  void _deleteEmployee(String id) async {
    try {
      await _firestore.collection('employees').doc(id).delete();
      _fetchEmployees();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee deleted successfully')),
      );
    } catch (e) {
      print('Error deleting employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee')),
      );
    }
  }

  void _editEmployee(DocumentSnapshot employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEmployeeScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _employees?.length ?? 0, // Use null-aware operator and null check
      itemBuilder: (context, index) {
        final employee = _employees?[index];
        final data = employee?.data(); // Use null-aware operator
        if (data != null && data is Map<String, dynamic>) {
          final firstName = data['firstName'] as String? ?? '';
          final lastName = data['lastName'] as String? ?? '';
          final email = data['email'] as String? ?? '';

          return ListTile(
            title: Text('$firstName $lastName'),
            subtitle: Text(email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editEmployee(employee!);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteEmployee(employee!.id);
                  },
                ),
              ],
            ),
          );
        } else {
          return SizedBox(); // Return an empty widget if data is not valid
        }
      },
    );
  }
}


class EditEmployeeScreen extends StatefulWidget {
final DocumentSnapshot employee;

const EditEmployeeScreen({required this.employee});

@override
_EditEmployeeScreenState createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.employee['firstName']);
    _lastNameController = TextEditingController(text: widget.employee['lastName']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    try {
      await widget.employee.reference.update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee details updated successfully')),
      );
    } catch (e) {
      print('Error updating employee details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update employee details')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}