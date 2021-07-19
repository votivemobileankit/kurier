import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/already_have_an_account_acheck.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/Login/component/background.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:kurier/view/signup/signup_screen.dart';
import 'package:passwordfield/passwordfield.dart';

import '../../home/HomeActivity.dart';

class Body extends StatefulWidget {
  @override
  Login createState() => Login();
}

class Login extends State<Body> {
  String email;
  String password;
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final SecureStorage secureStorage = SecureStorage();
  bool isLoading = false;
  final focus = FocusNode();
  final TextEditingController mobileController = new TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              Image.asset(
                "assets/icon/applogo.png",
                height: size.height * 0.15,
              ),
              SizedBox(height: size.height * 0.03),
              buildemail(context),
              buildpassword(context),
              RoundedButton(
                  text: "LOGIN",
                  press: () {
                    if (!globalKey.currentState.validate()) {
                      return;
                    }
                    globalKey.currentState.save();
                    LoginUser(context);
/*
                    if (mobileController == null) {
                      Fluttertoast.showToast(
                          msg: "Please Enter Password",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          //    timeInSecForIos: 1,
                          backgroundColor: Color(0xff2199c7),
                          textColor: Colors.red,
                          fontSize: 16.0);
                    } else {
                      LoginUser(context);
                    }*/
                  }),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildemail(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            icon: Icon(
              Icons.email,
            ),
            hintText: "Email",
            //labelText: "Email",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          onSaved: (String value) {
            email = value;
          },
        ));
  }

  Widget buildpassword(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        /*child:  TextFormField(
          keyboardType: TextInputType.text,
          controller: _userPasswordController,
          obscureText: !_passwordVisible,//This will obscure text dynamically
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            // Here is key idea
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),*/

        child: TextFormField(
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          focusNode: focus,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            hintText: "Password",
            border: InputBorder.none,
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is required';
            }
          },
          onSaved: (String value) {
            password = value;
          },
        ));
  }

  Future LoginUser(BuildContext context) async {
    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/login');
    Map mapeddate = {
      'email': email,
      'password': password,
    };
    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    int status = data['status'];
    print("DATA: ${status}");
    if (status == 1) {
      List data1 = data['data'];
      print("DATA: ${data1}");
      for (var i = 0; i < data1.length; i++) {
        print(data1[i]['driver_id']);
        secureStorage.writeSecureData('driverid', data1[i]['driver_id']);
        secureStorage.writeSecureData('firstname', data1[i]['first_name']);
        secureStorage.writeSecureData('surname', data1[i]['surname']);
        secureStorage.writeSecureData('email', data1[i]['email']);
        secureStorage.writeSecureData(
            'mobilenumber', data1[i]['mobile_number']);
        secureStorage.writeSecureData('address', data1[i]['address']);
        secureStorage.writeSecureData('city', data1[i]['city']);
        secureStorage.writeSecureData('postcode', data1[i]['post_code']);
        secureStorage.writeSecureData('status', data1[i]['status']);
      }
      ;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ListApp();
          },
        ),
      );
      /*Route route = MaterialPageRoute(builder: (context) => GroceryHomePage());
      Navigator.pushReplacement(context, route);*/
    } else {
      Fluttertoast.showToast(
          msg: "Unable to login please check email and password",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //    timeInSecForIos: 1,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }
}
