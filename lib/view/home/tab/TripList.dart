import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:kurier/session/SecureStorage.dart';

import 'package:kurier/view/home/tab/ProfilePage.dart';
import 'package:kurier/view/parcel/ParcelListActivity.dart';

import '../AddParcelList.dart';
import '../AddTripList.dart';
import '../RestaurantList.dart';
import 'DriverHistory.dart';

List<TripList> _TripList = [];

class TripList {
  final String trip_id, name, driver_id, parcel_id, status;
  final String trip_assign_status, created_date, updated_date, restaurant_id;

  TripList(
      {this.trip_id,
        this.name,
        this.driver_id,
        this.parcel_id,
        this.status,
        this.trip_assign_status,
        this.created_date,
        this.updated_date,
        this.restaurant_id});

  factory TripList.fromJson(Map<String, dynamic> json) {
    return new TripList(
      trip_id: json['trip_id'],
      name: json['name'],
      driver_id: json['driver_id'],
      parcel_id: json['parcel_id'],
      status: json['status'],
      trip_assign_status: json['trip_assign_status'],
      created_date: json['created_date'],
      updated_date: json['updated_date'],
      restaurant_id: json['restaurant_id'],
    );
  }
}

class ListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Flutter Demo',
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),*/
      home: MyListPage(),
    );
  }
}

class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

String driver_id;
String restaurant_id;

class _MyListPageState extends State<MyListPage> {
  ScrollController controller = ScrollController();
  final SecureStorage secureStorage = SecureStorage();
  bool closeTopContainer = false;
  double topContainer = 0;
  List<Widget> itemsData = [];

  // ProgressHUD _progressHUD;
  bool _loading = true;
  int _selectedIndex = 0;
  int _selectedIndex2 = 2;
  int _selectedIndex1 = 1;
  List<Widget> _widgetOptions = <Widget>[
    ListApp(),
    ProfilePage(),
  ];

  /*void getPostsData(String driverid, String restaurant_id) async {
    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/getTripList');
    Map mapeddate = {"driver_id": driverid, "restaurant_id": restaurant_id};
    print(driverid);
    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    int status = data['status'];
    print("status====: ${status}");
    List data1 = data['data'];

    List<dynamic> responseList = data1;
    if (status == 0) {
      if (data1.length == 0) {
        NoTada(context);
        print("isEmpty:");
        dismissProgressHUD();
      }
      print("DATA: ${data1}");
    } else {
      dismissProgressHUD();
      print("DATA: ${data1}");
    }

    List<Widget> listItems = [];
    responseList.forEach((post) {
      print("post: ${post}");
      listItems.add(Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 1.0),
              ]),
          child: InkWell(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'Trip Name :' + post["name"],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      RaisedButton(
                        child: new Text("Add Parcel"),
                        textColor: Colors.white,
                        color: Colors.blue,
                        onPressed: () {
                          Route route = MaterialPageRoute(
                              builder: (context) => AddParcelList(
                                  tripid: post["trip_id"],
                                  driver_id: post["driver_id"]));
                          Navigator.pushReplacement(context, route);

                          */ /*     Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddParcelList(
                                      tripid: post["trip_id"],
                                      driver_id: post["driver_id"])));
                      */ /*
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute<Null>(builder: (BuildContext context) {
                return new MyParcelListPage(
                    tripid: post["trip_id"], driver_id: post["driver_id"]);
              }))
            },
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }
*/
  Future<Null> getPostsData(String driver_id, String restaurant_id) async {

    _TripList.clear();

    Map mapeddate = {"driver_id": driver_id, "restaurant_id": restaurant_id};
    print("mapeddate: ${mapeddate}");
    print("url>>: ${url}");

    final response = await http.post(Uri.parse(url), body: mapeddate);
    final responseJson = json.decode(response.body);
    int status = responseJson['status'];
    List data1 = responseJson['data'];

    print("DATA: ${data1}");
    print("status: ${status}");
    List<dynamic> responseList = data1;
    print("responseJson>>: ${data1}");
    setState(() {
      for (Map user in data1) {
        _TripList.add(TripList.fromJson(user));
      }
    });
  }

  @override
  void initState() {
    secureStorage.readSecureData("driverid").then((value1) {
      driver_id = value1;
      print("driverid: ${driver_id}");
    });

    secureStorage.readSecureData("restaurant_id").then((value) {
      restaurant_id = value;
      print("restaurant_id: ${restaurant_id}");

      if (restaurant_id == null || restaurant_id.isEmpty) {
        _showLayout(context);
      } else {
        getPostsData(driver_id, restaurant_id);
        print("getPostsData: ");
      }
    });

    /* _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      text: 'Loading...',
    );*/

    controller.addListener(() {
      double value = controller.offset / 119;
      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });

    super.initState();
  }

  void handleClick(String value) {
    switch (value) {
      case 'Select Restaurant':
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RestaurantList()));
        break;
      case 'Add Trip':
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AddTripList()));

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double categoryHeight = size.height*0.30;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip List'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Select Restaurant', 'Add Trip'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            new Container(
              child: ListView.builder(
                itemCount: _TripList.length,
                itemBuilder: (context, index) {
                  return new Card(
                    child:  Container(
                        height: 100,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withAlpha(120),
                                  blurRadius: 1.0),
                            ]),
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                        fit: FlexFit.loose,
                                        child: Text(
                                          'Trip Name :' +
                                              _TripList[index].name,
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    RaisedButton(
                                      child: new Text("Add Parcel"),
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      onPressed: () {
                                        Route route = MaterialPageRoute(
                                            builder: (context) =>
                                                AddParcelList(
                                                    tripid:
                                                    _TripList[index]
                                                        .trip_id,
                                                    driver_id:
                                                    _TripList[index]
                                                        .driver_id));
                                        Navigator.pushReplacement(
                                            context, route);
                                      },
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(
                                              20.0)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () => {
                            Navigator.of(context).push(
                                MaterialPageRoute<Null>(
                                    builder: (BuildContext context) {
                                      return new MyParcelListPage(
                                          tripid: _TripList[index].trip_id,
                                          driver_id: _TripList[index].driver_id);
                                    }))
                          },
                        )),
                    margin: const EdgeInsets.all(0.0),
                  );
                },
              ),
            ),

            /*  new Expanded(
              child: ListView.builder(
                itemCount: _TripList.length,
                itemBuilder: (context, index) {
                  return new Card(
                    child: new ListTile(
                        title: new Text(_TripList[index].name),
                        subtitle: Text('${_TripList[index].updated_date}'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                            return new MyParcelListPage(
                                tripid: _TripList[index].trip_id,
                                driver_id: _TripList[index].driver_id);
                          }));
                        }),
                    margin: const EdgeInsets.all(0.0),
                  );
                },
              ),
            ),*/
            //  _progressHUD,
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('HOME'),
              activeIcon: Icon(
                FontAwesome.home,
                color: Colors.blue,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              title: Text('HISTORY'),
              activeIcon: Icon(
                FontAwesome.history,
                color: Colors.blue,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              activeIcon: Icon(
                FontAwesome.user,
                color: Colors.blue,
              ),
            ),
          ],
          onTap: (index) {
            setState(() {
              if (_selectedIndex == index) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ListApp()));
              } else if (_selectedIndex2 == index) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              } else {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => DriverHistory()));
              }
            });
          },
        ),
      ),
    );
  }

/*
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
*/

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: roundedButton(
                "No", const Color(0xFF167F67), const Color(0xFFFFFFFF)),
          ),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: roundedButton(
                " Yes ", const Color(0xFF167F67), const Color(0xFFFFFFFF)),
          ),
        ],
      ),
    ) ??
        false;
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }
}

_showLayout(BuildContext context) async {
  print("_showLayout:");
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Please select restaurant'),
        actions: <Widget>[
          FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute<Null>(builder: (BuildContext context) {
                      return new RestaurantList();
                    }));
              }),
        ],
      );
    },
  );
}

final String url = 'https://votivetech.in/courier/webservice/api/getTripList';

NoTada(BuildContext context) async {
  print("_showLayout:");
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('You dont have any Trip'),
        actions: <Widget>[
          FlatButton(child: Text('OK'), onPressed: () {}),
        ],
      );
    },
  );
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(
        child: FlatButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Screen2()));
          },
          child: Text('Go to next screen'),
          color: Colors.white,
        ),
      ),
    );
  }
}

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlueAccent,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Screen 2',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              margin: EdgeInsets.all(16),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back'),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
