import 'package:flutter/material.dart';
import 'pos_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drink POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: POSHomeWrapper(),
    );
  }
}

class POSHomeWrapper extends StatefulWidget {
  @override
  _POSHomeWrapperState createState() => _POSHomeWrapperState();
}

class _POSHomeWrapperState extends State<POSHomeWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    POSHomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  SizedBox(height: 10),
                  Text('Welcome, User', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Drink POS'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
     
    );
  }
}
