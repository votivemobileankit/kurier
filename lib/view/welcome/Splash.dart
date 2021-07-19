import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/utils/color.dart';
import 'package:kurier/view/Login/login_screen.dart';
import 'package:kurier/view/home/tab/TripList.dart';


import '../home/HomeActivity.dart';

String Driverid;
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SecureStorage secureStorage = SecureStorage();
  @override
  void initState() {
    // TODO: implement initState
    secureStorage.readSecureData("driverid").then((value){
      Driverid=value;
    });
    Timer(const Duration(milliseconds: 4000), () {
      if(Driverid==null){
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }else{
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ListApp()));
      }

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [orangeColors, orangeLightColors],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter),
        ),
        child: Center(
          child: Image.asset("assets/icon/applogo.png",
            height: size.height * 0.25),
        ),
      ),
    );
  }
}