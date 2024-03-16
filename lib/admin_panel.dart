import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class admin_panel extends StatefulWidget {
  admin_panel({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<admin_panel> createState() => _admin_panelState();
}

class _admin_panelState extends State<admin_panel> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  // Define the content for each option
  static final List<Widget> _widgetOptions = [
    Text(
      'Dashboard Content',
      style: optionStyle,
    ),
    Text(
      'Team Content',
      style: optionStyle,
    ),
    Text(
      'NO item available for Teamsheets',
      style: optionStyle,
    ),
    Text(
      'NO item available for Add Project +',
      style: optionStyle,
    ),
    // Content for Add Employe +
    ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First Name',
              style: TextStyle(
                fontFamily: 'OleoScript', // Specify the font family
                fontSize: 16, // Example font size
                fontWeight: FontWeight.bold, // Example font weight
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter First Name',
              ),
            ),
            Text(
              'Last Name',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Last Name',
              ),
            ),
            Text(
              'Email',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Email',
              ),
            ),
            Text(
              'Role Type',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Role Type',
              ),
            ),
            Text(
              'Date of Joining',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Date of Joining',
              ),
            ),
            Text(
              'Unique ID or EMP CODE',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Unique ID or EMP CODE',
              ),
            ),
            Text(
              'Mobile no.',
              style: optionStyle,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter Mobile no.',

              ),
            ),
            Text(
              'Password',
              style: optionStyle,
            ),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle button tap
              },
              child: Text('Add Employee'),
            ),
          ],
        ),
      ],
    ) ,
    Text(
      'NO item available for Add Role +',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _widgetOptions.length) {
        _selectedIndex = index;
      } else {
        // Handle index out of range
        print('Index out of range');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Page")),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/image/icons8-flutter-192(-xxxhdpi).png',
                    height: 100,
                    width: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('Team'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              title: const Text('Teamsheets'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              title: const Text('Add Project +'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              title: const Text('Add Employe +'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
            ListTile(
              title: const Text('Add Role +'),
              selected: _selectedIndex == 5,
              onTap: () => _onItemTapped(5),
            ),
          ],
        ),
      ),
    );
  }
}
