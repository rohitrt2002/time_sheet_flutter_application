import 'package:flutter/material.dart';
class UserPanel extends StatefulWidget {
  const UserPanel({Key? key}) : super(key: key);

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = [
    Text(
      'Dashboard Content',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    Text(
    'Team Content',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    ];
    return Scaffold(
      appBar:  AppBar (title: Text("User Page"),),
      body: Center (
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer (
        child: ListView(
          padding: EdgeInsets.zero,
          children: [DrawerHeader(
              decoration : BoxDecoration(color: Colors.blue,),
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
              title: const Text('Project List'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('Time sheet List'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
          ],

        )
      ),
    ) ;
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

