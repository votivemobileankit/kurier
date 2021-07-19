import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/Parcel.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/view/Tracking/MapPage.dart';
import 'package:kurier/view/Tracking/NewMapScreen.dart';
import 'package:kurier/view/home/HomeActivity.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:progress_hud/progress_hud.dart';

class MyParcelListPage extends StatefulWidget {
  final String tripid;
  final String driver_id;

  MyParcelListPage({
    this.tripid,
    this.driver_id,
  });

  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyParcelListPage> {
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];
  String parcelstatus;
  bool viewVisible = true;

  String Buttontext;

  ProgressHUD _progressHUD;
  bool _loading = true;

  void getPostsData() async {
    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/getParceList');
    Map mapeddate = {"trip_id": widget.tripid};
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
      parcelstatus = post["status"];

      if (parcelstatus == "1") {
        Buttontext = "Ready To Dispatched";
      } else {
        Buttontext = "Parcel Dispatched";
      }
      listItems.add(Container(
          height: 220,
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
                                      child: Icon(Icons.person),
                                    ),
                                  ),
                                  TextSpan(text: 'Reciever Name : '),
                                  TextSpan(text: post["first_name"]),
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
                                      child: Icon(Icons.call),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Reciever Number : ',
                                  ),
                                  TextSpan(text: post["customer_number"]),
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
                                      child: Icon(Icons.gps_fixed),
                                    ),
                                  ),
                                  TextSpan(text: 'Pickup Address : '),
                                  TextSpan(text: post["pic_up_location"]),
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
                                      child: Icon(Icons.location_city),
                                    ),
                                  ),
                                  TextSpan(text: 'Drop Address : '),
                                  TextSpan(text: post["drop_location"]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                RoundedButton(
                  text: Buttontext,
                  press: () {
                    print("parcel_id---${post["parcel_id"]}");

                    print(parcelstatus);
                    if (post["status"] == "1") {
                      Route route = MaterialPageRoute(
                          builder: (context) => NewMapScreen(
                              tripid: widget.tripid,
                              parcel_id: post["parcel_id"],
                              picklat: post["pickup_latitude"],
                              picklong: post["pickup_longitude"],
                              droplat: post["drop_latitude"],
                              droplong: post["drop_longitude"],
                              driver_id: widget.driver_id));
                      Navigator.pushReplacement(context, route);
                    } else {
                      Fluttertoast.showToast(
                          msg: "Parcel Dispatched already",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          //    timeInSecForIos: 1,
                          backgroundColor: Color(0xff2199c7),
                          textColor: Colors.red,
                          fontSize: 16.0);
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getPostsData();
    controller.addListener(() {
      double value = controller.offset / 119;
      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });

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
        title: new Text('Parcel List'),
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
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: closeTopContainer ? 0 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: size.width,
                    alignment: Alignment.topLeft,
                    //height: closeTopContainer?0:categoryHeight,
                    //child: categoriesScroller
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        controller: controller,
                        itemCount: itemsData.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          double scale = 1.0;
                          if (topContainer > 0.5) {
                            scale = index + 0.5 - topContainer;
                            if (scale < 0) {
                              scale = 0;
                            } else if (scale > 1) {
                              scale = 1;
                            }
                          }
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
