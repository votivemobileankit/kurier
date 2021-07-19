import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'HomeActivity.dart';

String driver_id;

class RestaurantList extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<RestaurantList> {
  TextEditingController controller = new TextEditingController();

  TextEditingController _textFieldController = TextEditingController();

  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails(String text) async {
    print("url>>: ${text}");
    _userDetails.clear();
    _searchResult.clear();
    Map mapeddate = {
      'search_key': text,
      'start_value': "0",
    };
    print("mapeddate: ${mapeddate}");
    print("url>>: ${url}");

    final response = await http.post(Uri.parse(url), body: mapeddate);
    final responseJson = json.decode(response.body);
    int status = responseJson['status'];
    List data1 = responseJson['data'];
    /* if (status == 0) {
      if (data1.length == 0) {
        NoDataLayout(context);
        print("isEmpty:");
      }
    }*/

    print("DATA: ${data1}");
    print("status: ${status}");
    List<dynamic> responseList = data1;
    print("responseJson>>: ${data1}");
    setState(() {
      for (Map user in data1) {
        _userDetails.add(UserDetails.fromJson(user));
      }
    });
  }

  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();

    secureStorage.readSecureData("driverid").then((value1) {
      driver_id = value1;
      print("driverid: ${driver_id}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: _buildAppBarOne("Connect with restaurant"),
        body: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColor,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: (text) {
                        getUserDetails(text);
                      },
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: ListView.builder(
                itemCount: _userDetails.length,
                itemBuilder: (context, index) {
                  return new Card(
                    child: new ListTile(
                        leading: new CircleAvatar(
                          backgroundImage: new NetworkImage(
                            _userDetails[index].restaurant_image,
                          ),
                        ),
                        title: new Text(_userDetails[index].restaurant_name),
                        subtitle: Text('${_userDetails[index].street_address}'),
                        onTap: () {
                          _showLayout(_userDetails[index].restaurant_id);
                        }),
                    margin: const EdgeInsets.all(0.0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Restaurant List'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute<Null>(builder: (BuildContext context) {
                return new ListApp();
              }));
            }));
  }

  Future<bool> _onBackPressed() {
    Route route = MaterialPageRoute(builder: (context) => ListApp());
    Navigator.pushReplacement(context, route);
  }

  _showLayout(String restaurant_id) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verify restaurant'),
          content: TextField(
            controller: _textFieldController,
            decoration:
                InputDecoration(hintText: "Please enter 6 digit passcode"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
                _textFieldController.clear();
              },
            ),
            FlatButton(
                child: Text('OK'),
                onPressed: () {
                  VerifyPassCode(context, _textFieldController.text,
                      restaurant_id, secureStorage);
                }),
          ],
        );
      },
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _userDetails.forEach((userDetail) {
      if (userDetail.first_name.contains(text) ||
          userDetail.surname.contains(text)) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

NoDataLayout(BuildContext context) async {
  print("_showLayout:");
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Data not found'),
        actions: <Widget>[
          FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute<Null>(builder: (BuildContext context) {
                  return new ListApp();
                }));
              }),
        ],
      );
    },
  );
}

List<UserDetails> _searchResult = [];

List<UserDetails> _userDetails = [];

final String url =
    'https://votivetech.in/courier/webservice/api/getAllRestaurantList';

class UserDetails {
  final String restaurant_id, first_name, surname, restaurant_name;
  final String mobile_number, email, street_address, restaurant_image;

  UserDetails(
      {this.restaurant_id,
      this.first_name,
      this.surname,
      this.restaurant_name,
      this.mobile_number,
      this.email,
      this.street_address,
      this.restaurant_image});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      restaurant_id: json['restaurant_id'],
      first_name: json['first_name'],
      surname: json['surname'],
      restaurant_name: json['restaurant_name'],
      mobile_number: json['mobile_number'],
      email: json['email'],
      street_address: json['address'],
      restaurant_image: json['restaurant_image'],
    );
  }
}

Future VerifyPassCode(BuildContext context, String text, String restaurant_id,
    SecureStorage secureStorage) async {
  var APIURL = Uri.parse(
      'https://votivetech.in/courier/webservice/api/connect_resturent');
  Map mapeddate = {
    'driver_id': driver_id,
    'restaurant_id': restaurant_id,
    'connectivity_number': text,
  };

  print("mapeddate: ${mapeddate}");
  Response response = await post(APIURL, body: mapeddate);
  var data = jsonDecode(response.body);
  print("addTrip: ${data}");
  print("mapeddate: ${mapeddate}");
  final responseJson = json.decode(response.body);

  int status = data['status'];
  List data1 = responseJson['data'];

  print("DATA: ${data1}");
  print("status: ${status}");
  if (status == 1) {
    secureStorage.writeSecureData('restaurant_id', restaurant_id);
    //  secureStorage.writeSecureData('restaurant_id', mRestaurantList[index].restaurant_id);
    Route route = MaterialPageRoute(builder: (context) => ListApp());
    Navigator.pushReplacement(context, route);
  } else {
    Fluttertoast.showToast(
        msg: data1.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        //    timeInSecForIos: 1,
        backgroundColor: Color(0xff2199c7),
        textColor: Colors.red,
        fontSize: 16.0);
  }
}
