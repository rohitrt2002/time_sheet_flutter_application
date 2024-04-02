import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _projectNameController;

  List<String> _selectedEmployees = [];

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(labelText: 'Project Name'),
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
                    final employeeData = employee.data() as Map<String, dynamic>;
                    final employeeName = '${employeeData['firstName']} ${employeeData['lastName']}';
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
                _addProject();
              },
              child: Text('Add Project'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProject() async {
    try {
      await _firestore.collection('projects').add({
        'projectName': _projectNameController.text,
        'allocatedEmployees': _selectedEmployees,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project added successfully')),
      );
      // Navigate to a different screen here

    } catch (e) {
      print('Error adding project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add project')),
      );
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }
}



class ProjectList extends StatefulWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _projects = [];
  Map<String, List<String>> _allocatedEmployeesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('projects').get();
      setState(() {
        _projects = querySnapshot.docs;
      });
      await _fetchAllocatedEmployees();
    } catch (e) {
      print('Error fetching projects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch projects')),
      );
    }
  }

  Future<void> _fetchAllocatedEmployees() async {
    try {
      for (DocumentSnapshot project in _projects) {
        List<String> allocatedEmployeeIds = ((project.data() as Map<String, dynamic>?)?['allocatedEmployees'] as List<dynamic>?)?.map((e) => e.toString())?.toList() ?? [];
        List<String> employeeNames = [];

        for (String employeeId in allocatedEmployeeIds) {
          DocumentSnapshot employeeSnapshot = await _firestore.collection('employees').doc(employeeId).get();
          Map<String, dynamic>? employeeData = employeeSnapshot.data() as Map<String, dynamic>?;

          if (employeeData != null) {
            String firstName = employeeData['firstName'] as String? ?? '';
            String lastName = employeeData['lastName'] as String? ?? '';
            employeeNames.add('$firstName $lastName');
          }
        }

        _allocatedEmployeesMap[project.id] = employeeNames;
      }

      setState(() {});
    } catch (e) {
      print('Error fetching allocated employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch allocated employees')),
      );
    }
  }

  void _deleteProject(String id) async {
    try {
      await _firestore.collection('projects').doc(id).delete();
      await _fetchProjects();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project deleted successfully')),
      );
    } catch (e) {
      print('Error deleting project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete project')),
      );
    }
  }

  void _editProject(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProjectScreen(projectId: id)),
    );
  }

  void _navigateToAddProjectScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProjectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project List'),
      ),
      body: ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          final data = project.data();
          if (data != null && data is Map<String, dynamic>) {
            final projectName = data['projectName'] as String? ?? '';
            final allocatedEmployees = _allocatedEmployeesMap[project.id] ?? [];

            return ListTile(
              title: Text(projectName),
              subtitle: Text('Allocated Employees: ${allocatedEmployees.join(', ')}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editProject(project.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProject(project.id);
                    },
                  ),
                ],
              ),
            );
          } else {
            return SizedBox(); // Return an empty widget if data is not valid
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProjectScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
class EditProjectScreen extends StatefulWidget {
  final String projectId;

  EditProjectScreen({required this.projectId});

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _projectNameController;

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                hintText: 'Enter new project name',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateProjectName();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProjectName() {
    String newProjectName = _projectNameController.text;
    print('New Project Name: $newProjectName');
    Navigator.pop(context);
  }
}

void main() {
  runApp(MaterialApp(
    home: ProjectList(),
  ));
}