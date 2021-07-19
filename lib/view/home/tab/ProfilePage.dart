import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/Login/login_screen.dart';
import '../HomeActivity.dart';
import 'TripList.dart';

String driverid;
String fullname;
String surname;
String mobile;
String email;
String address;
String city;
String pincode;
String imageholder;
NetworkImage image;

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final SecureStorage secureStorage = SecureStorage();
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final TextEditingController fullnameController = new TextEditingController();
  final TextEditingController surnameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController mobileController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController cityController = new TextEditingController();
  final TextEditingController postcodeController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    fetchdriverid();
    fetchdriverimage();
    /*secureStorage.readSecureData("driverid").then((value){
      setState((){
        driverid=value;
      });

     // print("checkid===${driverid}");
    });*/
    print(driverid);
    /*secureStorage.readSecureData("image").then((value1){
      setState((){
        imageholder=value1;
      });
      //print("checkid===${imageholder}");
    });*/
    print(imageholder);
    secureStorage.readSecureData("firstname").then((value2) {
      fullname = value2;
      fullnameController.text = fullname;
    });
    secureStorage.readSecureData("surname").then((value3) {
      surname = value3;
      surnameController.text = surname;
    });
    secureStorage.readSecureData("mobilenumber").then((value4) {
      mobile = value4;
      mobileController.text = mobile;
    });
    secureStorage.readSecureData("email").then((value5) {
      email = value5;
      emailController.text = email;
    });
    secureStorage.readSecureData("address").then((value6) {
      address = value6;
      addressController.text = address;
    });
    secureStorage.readSecureData("city").then((value7) {
      city = value7;
      cityController.text = city;
    });
    secureStorage.readSecureData("postcode").then((value8) {
      pincode = value8;
      postcodeController.text = pincode;
    });
    super.initState();
  }

  Future<bool> _onBackPressed() {
    Route route = MaterialPageRoute(builder: (context) => ListApp());
    Navigator.pushReplacement(context, route);
    false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: _buildAppBarOne("Add Trip"),
            body: new Container(
              color: Colors.white,
              child: Form(
                key: globalKey,
                child: new ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        /*
                    new Container(
                      height: 160.0,
                      color: Colors.white,
                      child: new Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: new Stack(
                                fit: StackFit.loose,
                                children: <Widget>[
                                  new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 70.0,
                                        backgroundImage: image,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ),*/
                        new Container(
                          color: Color(0xffFFFFFF),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 25.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Parsonal Information',
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _status
                                                ? _getEditIcon()
                                                : new Container(),
                                          ],
                                        ),
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _status
                                                ? _getLogoutIcon()
                                                : new Container(),
                                          ],
                                        )
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'FullName',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "Full Name"),
                                            enabled: !_status,
                                            autofocus: !_status,
                                            controller: fullnameController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Full Name is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              fullname = value;
                                            },
                                            onSaved: (String value) {
                                              fullname = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Surname',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "Surname"),
                                            enabled: !_status,
                                            autofocus: !_status,
                                            controller: surnameController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Surname is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              surname = value;
                                            },
                                            onSaved: (String value) {
                                              surname = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Email ID',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "Email ID"),
                                            enabled: !_status,
                                            controller: emailController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Email id is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              email = value;
                                            },
                                            onSaved: (String value) {
                                              email = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Mobile Number',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "Mobile Number"),
                                            enabled: !_status,
                                            controller: mobileController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Mobile Number is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              mobile = value;
                                            },
                                            onSaved: (String value) {
                                              mobile = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Full Address',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "Full Address"),
                                            enabled: !_status,
                                            controller: addressController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'Full Address is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              address = value;
                                            },
                                            onSaved: (String value) {
                                              address = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: new Text(
                                              'Post Code',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: new Text(
                                              'City',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.0),
                                            child: new TextFormField(
                                              decoration: const InputDecoration(
                                                  hintText: "Post Code"),
                                              enabled: !_status,
                                              controller: postcodeController,
                                              validator: (String value) {
                                                if (value.isEmpty) {
                                                  return 'Postcode is required';
                                                }
                                              },
                                              onChanged: (String value) {
                                                pincode = value;
                                              },
                                              onSaved: (String value) {
                                                pincode = value;
                                              },
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Flexible(
                                          child: new TextFormField(
                                            decoration: const InputDecoration(
                                                hintText: "City"),
                                            enabled: !_status,
                                            controller: cityController,
                                            validator: (String value) {
                                              if (value.isEmpty) {
                                                return 'City is required';
                                              }
                                            },
                                            onChanged: (String value) {
                                              city = value;
                                            },
                                            onSaved: (String value) {
                                              city = value;
                                            },
                                          ),
                                          flex: 2,
                                        ),
                                      ],
                                    )),
                                !_status
                                    ? _getActionButtons()
                                    : new Container(),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Profile'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              /* Navigator.of(context).push(
                  MaterialPageRoute<Null>(builder: (BuildContext context) {
                return new ListApp();
              }));*/
              Route route = MaterialPageRoute(builder: (context) => ListApp());
              Navigator.pushReplacement(context, route);
            }));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  if (!globalKey.currentState.validate()) {
                    return;
                  }
                  globalKey.currentState.save();
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                  UpdateUser(context);
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Widget _getLogoutIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.logout,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        showAlertDialog(context);
      },
    );
  }

  Future UpdateUser(BuildContext context) async {
    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/profileUpdate');
    Map mapeddate = {
      'driver_id': driverid,
      'first_name': fullname,
      'surname': surname,
      'mobile_number': mobile,
      'email': email,
      'address': address,
      'city': city,
      'post_code': pincode,
    };
    print(driverid);
    print(fullname);
    print(surname);
    print(mobile);
    print(email);
    print(address);
    print(city);
    print(pincode);
    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    print("DATA: ${data}");
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
    } else {
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

  fetchdriverid() async {
    secureStorage.readSecureData("driverid").then((value) {
      setState(() {
        driverid = value;
      });

      // print("checkid===${driverid}");
    });
  }

  fetchdriverimage() async {
    secureStorage.readSecureData("image").then((value1) {
      setState(() {
        //imageholder=value1;
        image = new NetworkImage(value1);
      });
      //print("checkid===${imageholder}");
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = RaisedButton(
      child: Text("No"),
      textColor: Colors.white,
      color: Colors.red,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0)),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = RaisedButton(
      child: Text("Yes"),
      textColor: Colors.white,
      color: Colors.green,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0)),
      onPressed: () {
        secureStorage.deleteSecureData('driverid');
        secureStorage.deleteSecureData('firstname');
        secureStorage.deleteSecureData('surname');
        secureStorage.deleteSecureData('email');
        secureStorage.deleteSecureData('mobilenumber');
        secureStorage.deleteSecureData('address');
        secureStorage.deleteSecureData('city');
        secureStorage.deleteSecureData('postcode');
        secureStorage.deleteSecureData('status');
        secureStorage.deleteSecureData('image');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginScreen();
            },
          ),
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Are you want to logout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
