import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_sheet_flutter_application/Employee_data.dart';
import 'package:time_sheet_flutter_application/add_role.dart';
import 'package:time_sheet_flutter_application/project_data.dart';
import 'package:time_sheet_flutter_application/team.dart';
import 'package:time_sheet_flutter_application/timesheetpaneladmin.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late int _employeeCount = 0;
  late int _projectCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch employee count
      final employeeQuery = await _firestore.collection('employees').get();
      setState(() {
        _employeeCount = employeeQuery.size;
      });

      // Fetch project count
      final projectQuery = await _firestore.collection('projects').get();
      setState(() {
        _projectCount = projectQuery.size;
      });
    } catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  Future<Map<String, int>?> _fetchDataFuture() async {
    try {
      // Fetch employee count
      final employeeQuery = await _firestore.collection('employees').get();
      final employeeCount = employeeQuery.size;

      // Fetch project count
      final projectQuery = await _firestore.collection('projects').get();
      final projectCount = projectQuery.size;

      return {
        'employeeCount': employeeCount,
        'projectCount': projectCount,
      };
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.grey,
      body: Container(
        color: Colors.grey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(color: Colors.white54),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.blueGrey,
                            child: Text(
                              'Total Employees',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.blueGrey,
                            child: Text(
                              _employeeCount.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.blueGrey,
                            child: Text(
                              'Total Projects',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.blueGrey,
                            child: Text(
                              _projectCount.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder<Map<String, int>?>(
                future: _fetchDataFuture(), // Fetch data asynchronously
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: Text('No data available'),
                    );
                  } else {
                    final data = snapshot.data!;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      // Disable GridView scrolling
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(16.0),
                      children: [
                        _buildGridItem(Icons.person, 'Employees',
                            data['employeeCount'] ?? 0, Colors.blue, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmployeeList()),
                              );
                            }),
                        _buildGridItem(Icons.assignment, 'Projects',
                            data['projectCount'] ?? 0, Colors.green, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectList()),
                              );
                            }),
                        _buildGridItem(
                            Icons.work, 'Roles', null, Colors.orange, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddRoleScreen()),
                          );
                        }),
                        _buildGridItem(
                            Icons.group, 'Teams', null, Colors.red, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddTeamScreen()),
                          );
                        }),
                        _buildGridItem(
                            Icons.timelapse, 'Timesheets', null,
                            Colors.purple, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => timesheetPanelScreen()),
                          );
                        }),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String text, int? count, Color color,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.blueGrey,
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: color),
            SizedBox(height: 10.0),
            Text(
              text,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            if (count != null)
              Text(
                '',
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
