import 'package:flutter/material.dart';
import 'package:kurier/view/Tracking/SignaturePage.dart';
import 'package:kurier/view/home/uploadImage.dart';
import 'package:kurier/view/welcome/Splash.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
    );
  }
}