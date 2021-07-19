
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/already_have_an_account_acheck.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/Login/login_screen.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:kurier/view/signup/component/background.dart';

import '../../home/HomeActivity.dart';

class Body extends StatelessWidget {
  String fullname;
  String surname;
  String mobile;
  String email;
  String password;
  String confirmpassword;
  String address;
  String city;
  String pincode;
  final GlobalKey<FormState>globalKey = GlobalKey<FormState>();
  final SecureStorage secureStorage = SecureStorage();
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();
  final focus6 = FocusNode();
  final focus7 = FocusNode();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child:Form(
        key: globalKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/icon/applogo.png",
              height: size.height * 0.10,
            ),
            SizedBox(height: size.height * 0.03),
            buildfullname(context),
            buildSurname(context),
            buildphone(context),
            buildemail(context),
            buildpassword(context),
            buildconfirmpassword(context),
            buildaddress(context),
            buildpincode(context),
            buildcity(context),

            RoundedButton(
              text: "SIGNUP",
              press: () {
                if (!globalKey.currentState.validate()) {
                  return;
                }
                globalKey.currentState.save();
                CircularProgressIndicator();
                RegisterUser(context);
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.05),
            /*OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {},
                ),
              ],
            )*/
          ],
        ),
      ),
      ),
    );
  }
  Widget buildfullname(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(Icons.person,),
            hintText: "Full Name",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Full Name is required';
            }
          },
          onSaved: (String value) {
            fullname = value;
          },
        )
    );

  }
  Widget buildSurname(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.name,
          focusNode: focus,
          decoration: InputDecoration(
            icon: Icon(Icons.person,),
            hintText: "Surname",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus1);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Surname is required';
            }
          },
          onSaved: (String value) {
            surname = value;
          },
        )
    );

  }
  Widget buildphone(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.phone,
          focusNode: focus1,
          decoration: InputDecoration(
            icon: Icon(Icons.call,),
            hintText: "Mobile",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus2);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Mobile is required';
            }
            if (!RegExp(
                r'(^(?:[+0]9)?[0-9]{10,12}$)')
                .hasMatch(value)){
              return'Please enter valid mobile number';
            }
            return null;

          },
          onSaved: (String value) {
            mobile = value;
          },
        )
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
        child :TextFormField(
          keyboardType: TextInputType.emailAddress,
          focusNode: focus2,
          decoration: InputDecoration(
            icon: Icon(Icons.email,),
            hintText: "Email",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus3);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)){
              return'Please enter a valid email address';
            }
            return null;
          },
          onSaved: (String value) {
            email = value;
          },
        )
    );

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
        child :TextFormField(
          keyboardType: TextInputType.visiblePassword,
          focusNode: focus3,
          decoration: InputDecoration(
            icon: Icon(Icons.lock,),
            hintText: "Password",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus4);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is required';
            }
          },
          onSaved: (String value) {
            password = value;
          },
        )
    );

  }
  Widget buildconfirmpassword(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.visiblePassword,
          focusNode: focus4,
          decoration: InputDecoration(
            icon: Icon(Icons.lock,),
            hintText: "Confirm Password",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus5);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Confirm Password is required';
            }
          },
          onSaved: (String value) {
            confirmpassword = value;
          },
        )
    );

  }
  Widget buildaddress(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.name,
          focusNode: focus5,
          decoration: InputDecoration(
            icon: Icon(Icons.add_location_rounded,),
            hintText: "Full Address",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus6);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Address is required';
            }
          },
          onSaved: (String value) {
            address = value;
          },
        )
    );

  }
  Widget buildcity(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.name,
          focusNode: focus6,
          decoration: InputDecoration(
            icon: Icon(Icons.add_location_rounded,),
            hintText: "City",
            border: InputBorder.none,),
          onFieldSubmitted: (v){
            FocusScope.of(context).requestFocus(focus7);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'City is required';
            }
          },
          onSaved: (String value) {
            city = value;
          },
        )
    );

  }
  Widget buildpincode(BuildContext context) {
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
        child :TextFormField(
          keyboardType: TextInputType.number,
          focusNode: focus7,
          decoration: InputDecoration(
            icon: Icon(Icons.person_pin,),
            hintText: "PostCode",
            border: InputBorder.none,),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Postcode is required';
            }
          },
          onSaved: (String value) {
            pincode = value;
          },
        )
    );

  }
 Future RegisterUser(BuildContext context) async {
    var APIURL = Uri.parse('https://votivetech.in/courier/webservice/api/driverRegistration');
    Map mapeddate = {
      'first_name': fullname,
      'surname': surname,
      'mobile_number': mobile,
      'email': email,
      'password': password,
      'address': address,
      'city': city,
      'post_code': pincode,
    };
    Response response = await post(APIURL,body:mapeddate);
    var data = jsonDecode(response.body);
    print("DATA: ${data}");
    int status= data['status'];
    print("DATA: ${status}");
    if(status==1){
      List data1 = data['data'];
      print("DATA: ${data1}");
      for(var i = 0; i< data1.length; i++) {
        print(data1[i]['driver_id']);
        secureStorage.writeSecureData('driverid', data1[i]['driver_id']);
        secureStorage.writeSecureData('firstname', data1[i]['first_name']);
        secureStorage.writeSecureData('surname', data1[i]['surname']);
        secureStorage.writeSecureData('email', data1[i]['email']);
        secureStorage.writeSecureData('mobilenumber', data1[i]['mobile_number']);
        secureStorage.writeSecureData('address', data1[i]['address']);
        secureStorage.writeSecureData('city', data1[i]['city']);
        secureStorage.writeSecureData('postcode', data1[i]['post_code']);
        secureStorage.writeSecureData('status', data1[i]['status']);
      };
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ListApp();
          },
        ),
      );
    }else{
      Fluttertoast.showToast(
          msg: "Email Already Exist",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //    timeInSecForIos: 1,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }

  }

}