import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/Parcel.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/Tracking/MapPage.dart';
import 'package:kurier/view/Tracking/NewMapScreen.dart';
import 'package:kurier/view/home/HomeActivity.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:kurier/view/parcel/ParcelListActivity.dart';
import 'package:progress_hud/progress_hud.dart';

import 'ParcelHistory.dart';


class DriverHistory extends StatefulWidget {
  @override
  HistoryScreen createState() => HistoryScreen();
}

class HistoryScreen extends State<DriverHistory> {
  ScrollController controller = ScrollController();
  List<Widget> itemsData = [];
  final SecureStorage secureStorage = SecureStorage();
  String driver_id;
  ProgressHUD _progressHUD;
  bool _loading = true;

  void getPostsData(String driver_id) async {
    var APIURL =
    Uri.parse('https://votivetech.in/courier/webservice/api/getTripHistory');
    Map mapeddate = {"driver_id": driver_id};

    print("mapeddate: ${mapeddate}");
    print("APIURL: ${APIURL}");

    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    int status = data['status'];
    List data1 = data['data'];
    print("DATA: ${data1}");
    print("status: ${status}");
    List<dynamic> responseList = data1;
    List<Widget> listItems = [];

    if (status == 1) {
      dismissProgressHUD();
    } else {
      dismissProgressHUD();
      if (data1.length == 0) {
        _showLayout(context);
        print("isEmpty:");
      }
    }

    responseList.forEach((post) {
      listItems.add(Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]),
          child: InkWell(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Icon(Icons.electric_bike),
                                    ),
                                  ),
                                  TextSpan(text: 'Trip : '),
                                  TextSpan(text: post["name"]),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Icon(Icons.restaurant),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Restaurant Name : ',
                                  ),
                                  TextSpan(text: post["restaurant_name"]),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              // maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0),
                                      child: Icon(Icons.date_range),
                                    ),
                                  ),
                                  TextSpan(text: 'Date : '),
                                  TextSpan(text: post["created_date"]),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute<Null>(builder: (BuildContext context) {
                    return new ParcelHistory(
                        tripid: post["trip_id"], driver_id: post["driver_id"]);
                  }))
            },
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    secureStorage.readSecureData("driverid").then((value) {
      driver_id = value;
      getPostsData(driver_id);
    });

    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      text: 'Loading...',
    );
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('History'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => ListApp());
              Navigator.pushReplacement(context, route);
            }));
  }

  Future<bool> _onBackPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
      return new ListApp();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double categoryHeight = size.height*0.30;
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: SafeArea(
          child: Scaffold(
            appBar: _buildAppBarOne("Parcel List"),
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[

                Container(
                    child: ListView.builder(
                        controller: controller,
                        itemCount: itemsData.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          double scale = 1.0;

                          return Opacity(
                            opacity: scale,
                            child: Transform(
                              transform: Matrix4.identity()
                                ..scale(scale, scale),
                              alignment: Alignment.bottomCenter,
                              child: Align(
                                  heightFactor: 0.85,
                                  alignment: Alignment.topCenter,
                                  child: itemsData[index]),
                            ),
                          );
                        })),
                _progressHUD,
              ],
            ),
          ),
        ));
  }

  void dismissProgressHUD() {
    setState(() {
      if (_loading) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }

      _loading = !_loading;
    });
  }
}

_showLayout(BuildContext context) async {
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
                Route route =
                MaterialPageRoute(builder: (context) => ListApp());
                Navigator.pushReplacement(context, route);
              }),
        ],
      );
    },
  );
}
