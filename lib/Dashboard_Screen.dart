import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;

class DashboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.orange,
      ),backgroundColor: Colors.grey,
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
                      child: Text('hbjhbbjhbhjbbhjbjhb',style: TextStyle(color: Colors.blueGrey),),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      height: 55,
                      padding: EdgeInsets.all(8.0),
                      color: Colors.blueGrey,
                      child: Center(child: Text('Live Project',
                        style: TextStyle(color: Colors.white ),)),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.blueGrey,
                      child: Text(
                        'Complete Project',
                        style: TextStyle(color: Colors.white),),
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
                      child: Center(child: Text('Total Project',
                        style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.blueGrey,
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text('70',
                        style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.blueGrey,
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text('30',
                        style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChart(total: 70, complete: 50, live: 30),
                  // Total, complete, and live projects
                ],
              ),*/
              FutureBuilder<Map<String, int>>(
                future: _fetchData(), // Fetch data asynchronously
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final data = snapshot.data!;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(16.0),
                      children: [
                        _buildGridItem(Icons.person, 'Employees',
                            data['employeeCount'] ?? 0, Colors.blue, () {
                              // Navigate to Employees screen
                            }),
                        _buildGridItem(Icons.assignment, 'Projects',
                            data['projectCount'] ?? 0, Colors.green, () {
                              // Navigate to Projects screen
                            }),
                        _buildGridItem(
                            Icons.work, 'Roles', null, Colors.orange, () {
                          // Navigate to Roles screen
                        }),
                        _buildGridItem(
                            Icons.group, 'Teams', null, Colors.red, () {
                          // Navigate to Teams screen
                        }),
                        _buildGridItem(
                            Icons.timelapse, 'Timesheets', null, Colors.purple, () {
                          // Navigate to Timesheets screen
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

  Future<Map<String, int>> _fetchData() async {
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
      throw ('Failed to fetch data: $e');
    }
  }

  Widget _buildPieChart({
    required double total,
    required double complete,
    required double live,
  }) {
    return Container(
      height: 300,
      width: 300,
      child: charts.SfCircularChart(
        series: <charts.CircularSeries>[
          charts.PieSeries<_ChartData, String>(
            dataSource: [
              _ChartData('Total', total),
              _ChartData('Complete', complete),
              _ChartData('Live', live),
            ],
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            dataLabelSettings: charts.DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside ,
            ),
          ),
        ],
      ),
    );
  }

}
  class _ChartData {
  _ChartData(this.category, this.value);

  final String category;
  final double value;
}