import 'package:flutter/material.dart';
import 'package:kurier/view/Login/component/body.dart';

import '../../utils/color.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBarOne("Login"),
      body: Body(),
    );
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
      bottom: PreferredSize(
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(1.0)),
      //automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColor,
      elevation: 0,
      title: Text(title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
