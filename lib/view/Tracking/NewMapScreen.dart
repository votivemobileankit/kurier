import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kurier/constants/MapPinPillComponent.dart';
import 'package:kurier/constants/RoundedWhiteButton.dart';
import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/model/PinInformation.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/Tracking/SignaturePage.dart';
import 'package:kurier/view/parcel/ParcelListActivity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

const double CAMERA_ZOOM = 12;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
LatLng SOURCE_LOCATION = LatLng(0, 0);
String driverid;
String pickup_lat;
String pickup_long;
String drop_lat;
String drop_long;

class NewMapScreen extends StatefulWidget {
  final String tripid;
  final String parcel_id;
  final String picklat;
  final String picklong;
  final String droplat;
  final String droplong;
  final String driver_id;

  LocationData currentLocation;

  NewMapScreen(
      {this.tripid,
      this.parcel_id,
      this.picklat,
      this.picklong,
      this.droplat,
      this.droplong,
      this.driver_id});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<NewMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  List<Widget> itemsData = [];
  Set<Polyline> _polylines = {};
  String googleAPIKey = "AIzaSyB6jpjQRZn8vu59ElER36Q2LaxptdAghaA";
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  List<TaskModel> listofTasks = new List<TaskModel>();
  final SecureStorage secureStorage = SecureStorage();
  int _selected;

  void getPostsData() async {
    var APIURL = Uri.parse(
        'https://votivetech.in/courier/webservice/api/getParcelDropLocationByDriverId');
    Map mapeddate = {
      "driver_id": widget.driver_id,
      "trip_id": widget.tripid,
    };
    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    print("APIURL>>>: ${APIURL}");
    int status = data['status'];

    pickup_lat = data['pickup_latitude'];
    pickup_long = data['pickup_longitude'];
    drop_lat = data['drop_latitude'];
    drop_long = data['drop_longitude'];

    List data1 = data['data'];
    print("MapPageState: ${data1}");
    List<dynamic> responseList = data1;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      TaskModel model = new TaskModel(
          post["parcel_id"],
          post["pic_up_location"],
          post["drop_location"],
          post["pickup_latitude"],
          post["pickup_longitude"],
          post["drop_latitude"],
          post["drop_longitude"]);

      listofTasks.add(model);

      print("listofTasks>>>: ${listofTasks.length}");
      print("model>>>: ${model}");
    });

    TaskModel model1 =
        new TaskModel("", "", "", drop_lat, drop_long, pickup_lat, pickup_long);
    listofTasks.add(model1);
    print("listofTasksnew>>>: ${listofTasks.length}");
    print("model1>>>: ${model1}");

    setState(() {
      itemsData = listItems;
    });
  }

  double pinPillPosition = -100;
  Location location;
  LocationData currentLocation;
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);

  @override
  void initState() {
    super.initState();

    print("parcel_id---${widget.parcel_id}");
    fetchdriverid();
    SOURCE_LOCATION =
        LatLng(double.parse(widget.picklat), double.parse(widget.picklong));
    print("widget.driver_id>>>: ${widget.driver_id}");
    getPostsData();
    takePermissions();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      print(
          "currentLocation>>>: ${currentLocation.latitude}${currentLocation.longitude}");
      updatePinOnMap();
      print("updatePinOnMap>>>: ${updatePinOnMap}");
      UpdateDriverlocation(
          context, currentLocation.latitude, currentLocation.longitude);
    });
  }

  Future<void> takePermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.camera.request().isGranted) {
      setSourceAndDestinationIcons();
    }
    var statuses = await [
      Permission.location,
      Permission.camera,
    ].request();
    print(statuses[Permission.camera]);
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Tracking '),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(
                  builder: (context) => MyParcelListPage(
                      tripid: widget.tripid, driver_id: widget.driver_id));
              Navigator.pushReplacement(context, route);
            }));
  }

  Future<bool> _onBackPressed() {
    Route route = MaterialPageRoute(
        builder: (context) => MyParcelListPage(
            tripid: widget.tripid, driver_id: widget.driver_id));
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: SOURCE_LOCATION);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: _buildAppBarOne("Parcel List"),
          body: Stack(children: <Widget>[
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialLocation,
                onMapCreated: onMapCreated),
            MapPinPillComponent(
                pinPillPosition: pinPillPosition,
                currentlySelectedPin: currentlySelectedPin),
            Align(
              alignment: Alignment.bottomCenter,
              child: RoundedButton(
                text: "Click After Dispatch Parcel",
                press: () {
                  /*  showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Select Parcel'),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),

                        content: SingleChildScrollView(
                          child: Container(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Divider(),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.4,
                                  ),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: listofTasks.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return RadioListTile(
                                            title: Text(listofTasks[index].name),
                                            value: index,
                                            groupValue: _selected,
                                            onChanged: (value) {
                                              setState(() {
                                                _selected = index;
                                                DispatchParcel(context, listofTasks[index].taskid, widget.tripid);
                                              });
                                            });
                                      }),
                                ),
                                Divider(),

                              ],
                            ),
                          ),
                        ),
                      ));*/

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute<Null>(builder: (BuildContext context) {
                    return new SignaturePage(
                        tripid: widget.tripid,
                        parcel_id: widget.parcel_id,
                        picklat: widget.picklat,
                        picklong: widget.picklong,
                        droplat: widget.droplat,
                        droplong: widget.droplong,
                        driver_id: widget.driver_id);
                  }));

                  //DispatchParcel(context, widget.parcelid, widget.tripid);
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: RoundedWhiteButton(
                text: "Start Naviation",
                press: () {
                  print("Ex--- ");
                  navigateTo(double.parse(widget.droplat),
                      double.parse(widget.droplong));
                },
              ),
            ),
          ]),
          /*  body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(

              child: GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                  onMapCreated: onMapCreated),
            ),

          ],
        ),
      ),
      */
        ));
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
  }

  void setMapPins() async {
    /*  TaskModel model = new TaskModel(
        "1", "Polyline 1", "", 22.7571, 75.8822, 22.7149, 75.8899);
    listofTasks.add(model);

    TaskModel model1 = new TaskModel(
        "2", "Polyline 2", "", 22.7149, 75.8899, 22.7344, 75.8903);

    TaskModel model2 = new TaskModel(
        "2", "Polyline 2", "", 22.7344, 75.8903, 22.7533, 75.8937);

    listofTasks.add(model1);
    listofTasks.add(model2);*/

    Polyline polyline;
    if (listofTasks != null && listofTasks.length > 0) {
      for (var one in listofTasks) {
        try {
          List<LatLng> polylineCoordinates = [];

          //LatLng SOURCE = LatLng(, one.slongitude);
          LatLng SOURCE =
              LatLng(double.parse(one.slatitude), double.parse(one.slongitude));
          //LatLng DEST = LatLng(one.dlatitude, one.dlongitude);
          LatLng DEST =
              LatLng(double.parse(one.dlatitude), double.parse(one.dlongitude));
          PolylinePoints polylinePoints = PolylinePoints();

          _markers.add(Marker(
              markerId: MarkerId('sourcePin' + one.taskid),
              position: SOURCE,
              icon: sourceIcon));
          _markers.add(Marker(
              markerId: MarkerId('destPin' + one.taskid),
              position: DEST,
              icon: destinationIcon));

          PolylineResult result =
          await polylinePoints?.getRouteBetweenCoordinates(
              googleAPIKey,
              PointLatLng(double.parse(one.slatitude),double.parse(one.slongitude)),
              PointLatLng(double.parse(one.dlatitude),double.parse(one.dlongitude))
          );

          print("result>>>-----    " + result.toString());
          if (result.status.isNotEmpty) {
            print("result>>>>>>>>>>    " + result.toString());
            result.points.forEach((element) {
              polylineCoordinates.add(LatLng(element.latitude, element.longitude));
            });

          }
          setState(() {
            polyline = Polyline(
                polylineId: PolylineId("poly" + one.taskid),
                color: Color.fromARGB(204, 147, 70, 140),
                width: 6,
                points: polylineCoordinates);
            _polylines.add(polyline);
          });
        } catch (e) {
          print("Ex--- $e");
        }
      }
    }
  }

  void updatePinOnMap() async {
    print("updatePinOnMap>async>>: ${updatePinOnMap}");
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));

      print(
          "currentLocation.latitude>>>: ${currentLocation.latitude}${currentLocation.longitude}");

      UpdateDriverlocation(
          context, currentLocation.latitude, currentLocation.longitude);
    });
  }

  fetchdriverid() async {
    secureStorage.readSecureData("driverid").then((value) {
      setState(() {
        driverid = value;
      });

      // print("checkid===${driverid}");
    });
  }

  static void navigateTo(double lat, double lng) async {
    print("Ex--- ");
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
      print("launch---");
    } else {
      print("Could not launch---");
      throw 'Could not launch ${uri.toString()}';
    }
  }
}

Future DispatchParcel(
    BuildContext context, String parcelid, String tripid) async {
  var APIURL =
      Uri.parse('https://votivetech.in/courier/webservice/api/parcelDelivered');
  Map mapeddate = {
    'parcel_id': parcelid,
    'status': "2",
  };
  Response response = await post(APIURL, body: mapeddate);
  var data = jsonDecode(response.body);
  print("DispatchParcel: ${data}");
  int status = data['status'];
  print("DispatchParcel: ${status}");
  if (status == 1) {
    // Navigator.pushReplacement(context,
    // MaterialPageRoute(builder: (context) => SignaturePage(parcelid)));
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

Future UpdateDriverlocation(
    BuildContext context, double latitude, double longitude) async {
  print("UpdateDriverlocation>>>: ${UpdateDriverlocation}");

  var APIURL = Uri.parse(
      'http://votivetech.in/courier/webservice/api/addUpdateDataLiveLocation');
  Map mapeddate = {
    'driver_id': driverid,
    'location_lat': latitude.toString(),
    'location_long': longitude.toString(),
  };

  print("APIURL: ${APIURL}");
  print("mapeddate: ${mapeddate}");
  Response response = await post(APIURL, body: mapeddate);
  var data = jsonDecode(response.body);
  print("UpdateDriverlocation: ${data}");

  int status = data['status'];
  print("UpdateDriverlocation: ${status}");

  /* if(status==1){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute<Null>(builder: (BuildContext context) {
            return new MyParcelListPage(
                tripid: widget.tripid);
          }));
    }else{
      Fluttertoast.showToast(
          msg: "Email Already Exist",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //    timeInSecForIos: 1,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }*/
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}

class TaskModel {
  String taskid;
  String name;
  String address;
  String slatitude;
  String dlatitude;
  String slongitude;
  String dlongitude;

  TaskModel(this.taskid, this.name, this.address, this.slatitude,
      this.slongitude, this.dlatitude, this.dlongitude);
}
