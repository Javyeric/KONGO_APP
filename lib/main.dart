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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: POSHomePage(),
    );
  }
}
