import 'package:flutter/material.dart';
import 'package:read_2_me/alternateHomeScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My reader prototype',
      theme: ThemeData(
        textTheme: TextTheme(
          title: TextStyle(color: Colors.white, fontSize: 36.00, fontWeight: FontWeight.bold),
          body1: TextStyle(color: Colors.white, fontSize: 18.00, fontFamily: 'Hind'),
          subtitle: TextStyle(color: Colors.white, fontSize: 14.00)
        ),
        primarySwatch: Colors.deepOrange,
      ),
      home: MyAlternateHomeScreen(title: 'News Reader'),
    );
  }
}

