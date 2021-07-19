import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'dart:convert';

import 'package:kurier/view/Login/component/background.dart';
import 'package:kurier/view/home/HomeActivity.dart';
import 'package:kurier/view/home/RestaurantList.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:progress_hud/progress_hud.dart';

class AddTripList extends StatefulWidget {
  @override
  TripListData createState() => TripListData();
}

String restaurant_id;
String driver_id;

class TripListData extends State<AddTripList> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    secureStorage.readSecureData("restaurant_id").then((value) {
      restaurant_id = value;
      print("restaurant_id: ${restaurant_id}");
    });

    secureStorage.readSecureData("driverid").then((value1) {
      driver_id = value1;
      print("driverid: ${driver_id}");
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: new Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBarOne("Add Trip"),
          body: AddTripListBody(),
        ));
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Add Trip'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => ListApp());
              Navigator.pushReplacement(context, route);
            }));
  }

  Future<bool> _onBackPressed() {
    Route route = MaterialPageRoute(builder: (context) => ListApp());
    Navigator.pushReplacement(context, route);
    false;
  }
}

class AddTripListBody extends StatelessWidget {
  String fullname;
  String surname;

  String parcel_id;
  String image_url;

  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
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
        child: Form(
          key: globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              buildfullname(context),
              RoundedButton(
                text: "Add Trip",
                press: () {
                  if (!globalKey.currentState.validate()) {
                    return;
                  }
                  globalKey.currentState.save();

                  if (restaurant_id == null) {
                    Fluttertoast.showToast(
                        msg: "Please Select First Restaurant",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        //    timeInSecForIos: 1,
                        backgroundColor: Color(0xff2199c7),
                        textColor: Colors.red,
                        fontSize: 16.0);

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RestaurantList()));
                  } else {
                    RegisterUser(context);
                  }

                  print("RegisterUser111: ${RegisterUser}");
                },
              ),
              SizedBox(height: size.height * 0.05),
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
        child: TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Trip Name",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Trip Name is required';
            }
          },
          onSaved: (String value) {
            fullname = value;
          },
        ));
  }

  Future RegisterUser(BuildContext context) async {
    print("RegisterUser>>>: ${RegisterUser}");

    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/addTrip');
    Map mapeddate = {
      'name': fullname,
      'driver_id': driver_id,
      'restaurant_id': restaurant_id,
    };

    print("mapeddate: ${mapeddate}");

    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    print("addTrip: ${data}");
    print("mapeddate: ${mapeddate}");

    int status = data['status'];
    int DATA = data['data'];

    if (status == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new ListApp();
      }));
    }
  }
}
