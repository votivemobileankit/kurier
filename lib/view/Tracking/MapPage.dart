// import 'dart:convert';
//
// import 'package:flutter/physics.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart';
// import 'package:kurier/constants/MapPinPillComponent.dart';
// import 'package:kurier/constants/rounded_button.dart';
// import 'package:kurier/model/PinInformation.dart';
// import 'package:kurier/session/SecureStorage.dart';
// import 'package:kurier/view/home/HomeActivity.dart';
// import 'package:kurier/view/home/tab/AddTripList.dart';
// import 'package:kurier/view/parcel/ParcelListActivity.dart';
// import 'package:location/location.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
//
// /*void main() =>
//     runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MapPage()));*/
// String driverid;
//
// class MapPage extends StatefulWidget {
//   final String tripid;
//   final String parcelid;
//   final String picklat;
//   final String picklong;
//   final String droplat;
//   final String droplong;
//   final String driver_id;
//
//
//   MapPage({this.tripid, this.parcelid, this.picklat, this.picklong, this.droplat, this.droplong, this.driver_id});
//
//   @override
//   State<StatefulWidget> createState() => MapPageState();
// }
//
// class MapPageState extends State<MapPage> {
//   double CAMERA_ZOOM = 16;
//   double CAMERA_TILT = 80;
//   double CAMERA_BEARING = 30;
//   LatLng SOURCE_LOCATION;
//
//   //LatLng SOURCE_LOCATION = LatLng(22.7196, 75.8577);
//   LatLng DEST_LOCATION;
//   List<TaskModel> listofTasks = new List<TaskModel>();
//
//   List<Widget> itemsData = [];
//   //LatLng DEST_LOCATION = LatLng(23.176500, 75.788500);
//
//   double _originLatitude = 26.48424, _originLongitude = 50.04551;
//   double _destLatitude = 26.46423, _destLongitude = 50.06358;
//   Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> _markers = Set<Marker>();
//
// // for my drawn routes on the map
//   Set<Polyline> _polylines = Set<Polyline>();
//   List<LatLng> polylineCoordinates = [];
//
//   //PolylinePoints polylinePoints;
//   //Map<PolylineId, Polyline> polylines = {};
//   String googleAPIKey = 'AIzaSyB6jpjQRZn8vu59ElER36Q2LaxptdAghaA';
//
// // for my custom marker pins
//   BitmapDescriptor sourceIcon;
//   BitmapDescriptor destinationIcon;
//
// // the user's initial location and current location
// // as it moves
//   LocationData currentLocation;
//
// // a reference to the destination location
//   LocationData destinationLocation;
//
// // wrapper around the location API
//   Location location;
//   double pinPillPosition = -100;
//   PinInformation currentlySelectedPin = PinInformation(
//       pinPath: '',
//       avatarPath: '',
//       location: LatLng(0, 0),
//       locationName: '',
//       labelColor: Colors.grey);
//   PinInformation sourcePinInfo;
//   PinInformation destinationPinInfo;
//   final SecureStorage secureStorage = SecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchdriverid();
//
//     getPostsData();
//
//
//     // create an instance of Location
//     location = new Location();
//     // polylinePoints = PolylinePoints();
//
//     // subscribe to changes in the user's location
//     // by "listening" to the location's onLocationChanged event
//     location.onLocationChanged.listen((LocationData cLoc) {
//       // cLoc contains the lat and long of the
//       // current user's position in real time,
//       // so we're holding on to it
//       currentLocation = cLoc;
//       updatePinOnMap();
//     });
//     // set custom marker pins
//     setSourceAndDestinationIcons();
//     // set the initial location
//     setInitialLocation();
//
//
//   }
//
//   void setSourceAndDestinationIcons() async {
//     BitmapDescriptor.fromAssetImage(
//             ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
//         .then((onValue) {
//       sourceIcon = onValue;
//     });
//
//     BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
//             'assets/destination_map_marker.png')
//         .then((onValue) {
//       destinationIcon = onValue;
//     });
//   }
//
//   void setInitialLocation() async {
//     // set the initial location by pulling the user's
//     // current location from the location's getLocation()
//     currentLocation = await location.getLocation();
//
//     // hard-coded destination for this example
//     destinationLocation = LocationData.fromMap({
//       "latitude": DEST_LOCATION.latitude,
//       "longitude": DEST_LOCATION.longitude
//     });
//     showPinsOnMap();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     CameraPosition initialCameraPosition = CameraPosition(
//         zoom: CAMERA_ZOOM,
//         tilt: CAMERA_TILT,
//         bearing: CAMERA_BEARING,
//         target: SOURCE_LOCATION);
//     if (currentLocation != null) {
//       initialCameraPosition = CameraPosition(
//           target: LatLng(currentLocation.latitude, currentLocation.longitude),
//           zoom: CAMERA_ZOOM,
//           tilt: CAMERA_TILT,
//           bearing: CAMERA_BEARING);
//     }
//     return WillPopScope(
//       onWillPop: _onBackPressed,
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             GoogleMap(
//                 myLocationEnabled: true,
//                 compassEnabled: true,
//                 tiltGesturesEnabled: false,
//                 zoomControlsEnabled: false,
//                 markers: _markers,
//                 polylines: _polylines,
//                 mapType: MapType.normal,
//                 initialCameraPosition: initialCameraPosition,
//                 onTap: (LatLng loc) {
//                   pinPillPosition = -100;
//                 },
//                 onMapCreated: (GoogleMapController controller) {
//                   controller.setMapStyle(Utils.mapStyles);
//                   _controller.complete(controller);
//                   // my map has completed being created;
//                   // i'm ready to show the pins on the map
//                   //showPinsOnMap();
//                 }),
//             MapPinPillComponent(
//                 pinPillPosition: pinPillPosition,
//                 currentlySelectedPin: currentlySelectedPin),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: RoundedButton(
//                 text: "Click After Dispatch Parcel",
//                 press: () {
//                   DispatchParcel(context);
//                   /*print(post["picklat"]);
//                   print(post["picklong"]);
//                   print(post["droplat"]);
//                   print(post["droplong"]);*/
//                   /*Navigator.of(context).push(
//                   MaterialPageRoute<Null>(builder: (BuildContext context) {
//                     */ /*           return new CategoryDetailsScreen(
//                     name: category[index].name,
//                     children: category[index].children);*/ /*
//
//                     return new MapPage(
//                         picklat: post["pickup_latitude"],
//                         picklong: post["pickup_longitude"],
//                         droplat: post["drop_latitude"],
//                         droplong: post["drop_longitude"]);
//                   }));*/
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   void showPinsOnMap() {
//     // get a LatLng for the source location
//     // from the LocationData currentLocation object
//     var pinPosition =
//         LatLng(currentLocation.latitude, currentLocation.longitude);
//     // get a LatLng out of the LocationData object
//     var destPosition =
//         LatLng(destinationLocation.latitude, destinationLocation.longitude);
//
//     sourcePinInfo = PinInformation(
//         locationName: "Start Location",
//         location: SOURCE_LOCATION,
//         pinPath: "assets/driving_pin.png",
//         avatarPath: "assets/friend1.jpg",
//         labelColor: Colors.blueAccent);
//
//     destinationPinInfo = PinInformation(
//         locationName: "End Location",
//         location: DEST_LOCATION,
//         pinPath: "assets/destination_map_marker.png",
//         avatarPath: "assets/friend2.jpg",
//         labelColor: Colors.purple);
//
//     // add the initial source location pin
//     _markers.add(Marker(
//         markerId: MarkerId('sourcePin'),
//         position: pinPosition,
//         onTap: () {
//           setState(() {
//             currentlySelectedPin = sourcePinInfo;
//             pinPillPosition = 0;
//           });
//         },
//         icon: sourceIcon));
//     // destination pin
//     _markers.add(Marker(
//         markerId: MarkerId('destPin'),
//         position: destPosition,
//         onTap: () {
//           setState(() {
//             currentlySelectedPin = destinationPinInfo;
//             pinPillPosition = 0;
//           });
//         },
//         icon: destinationIcon));
//     // set the route lines on the map from source to destination
//     // for more info follow this tutorial
//     setPolylines();
//   }
//
//   void setPolylines() async {
//     print(currentLocation.latitude);
//     print(currentLocation.longitude);
//     print(destinationLocation.latitude);
//     print(destinationLocation.longitude);
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPIKey,
//       PointLatLng(currentLocation.latitude, currentLocation.longitude),
//       PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
//       travelMode: TravelMode.driving,
//     );
//     print(result.points);
//
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//
//       /* setState(() {
//         PolylineId id = PolylineId("poly");
//         Polyline polyline = Polyline(
//             polylineId: id, color: Colors.red, points: polylineCoordinates);
//         polylines[id] = polyline;
//       });*/
//       setState(() {
//         _polylines.add(Polyline(
//             width: 5, // set the width of the polylines
//             polylineId: PolylineId("poly"),
//             color: Color.fromARGB(255, 40, 122, 198),
//             points: polylineCoordinates));
//       });
//     } else {
//       print("nopolyline");
//     }
//   }
//
//   void updatePinOnMap() async {
//     // create a new CameraPosition instance
//     // every time the location changes, so the camera
//     // follows the pin as it moves with an animation
//     CameraPosition cPosition = CameraPosition(
//       zoom: CAMERA_ZOOM,
//       tilt: CAMERA_TILT,
//       bearing: CAMERA_BEARING,
//       target: LatLng(currentLocation.latitude, currentLocation.longitude),
//     );
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
//     // do this inside the setState() so Flutter gets notified
//     // that a widget update is due
//     setState(() {
//       // updated position
//       var pinPosition =
//           LatLng(currentLocation.latitude, currentLocation.longitude);
//
//       sourcePinInfo.location = pinPosition;
//
//       // the trick is to remove the marker (by id)
//       // and add it again at the updated location
//       _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
//       _markers.add(Marker(
//           markerId: MarkerId('sourcePin'),
//           onTap: () {
//             setState(() {
//               currentlySelectedPin = sourcePinInfo;
//               pinPillPosition = 0;
//             });
//           },
//           position: pinPosition, // updated position
//           icon: sourceIcon));
//       UpdateDriverlocation(context);
//     });
//   }
//
//   Future DispatchParcel(BuildContext context) async {
//     var APIURL = Uri.parse(
//         'https://votivetech.in/courier/webservice/api/parcelDelivered');
//     Map mapeddate = {
//       'parcel_id': widget.parcelid,
//       'status': "2",
//     };
//     Response response = await post(APIURL, body: mapeddate);
//     var data = jsonDecode(response.body);
//     print("DATA: ${data}");
//     int status = data['status'];
//     print("DATA: ${status}");
//     if (status == 1) {
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute<Null>(builder: (BuildContext context) {
//         return new MyParcelListPage(tripid: widget.tripid);
//       }));
//     } else {
//       Fluttertoast.showToast(
//           msg: "Email Already Exist",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           //    timeInSecForIos: 1,
//           backgroundColor: Color(0xff2199c7),
//           textColor: Colors.red,
//           fontSize: 16.0);
//     }
//   }
//
//   Future UpdateDriverlocation(BuildContext context) async {
//     var APIURL = Uri.parse(
//         'https://votivetech.in/courier/webservice/api/addUpdateDataLiveLocation');
//     Map mapeddate = {
//       'driver_id': driverid,
//       'location_lat': currentLocation.latitude.toString(),
//       'location_long': currentLocation.longitude.toString(),
//     };
//     Response response = await post(APIURL, body: mapeddate);
//     var data = jsonDecode(response.body);
//     print("DATA: ${data}");
//     int status = data['status'];
//     print("DATA: ${status}");
//     /* if(status==1){
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute<Null>(builder: (BuildContext context) {
//             return new MyParcelListPage(
//                 tripid: widget.tripid);
//           }));
//     }else{
//       Fluttertoast.showToast(
//           msg: "Email Already Exist",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.BOTTOM,
//           //    timeInSecForIos: 1,
//           backgroundColor: Color(0xff2199c7),
//           textColor: Colors.red,
//           fontSize: 16.0);
//     }*/
//   }
//
//   fetchdriverid() async {
//     secureStorage.readSecureData("driverid").then((value) {
//       setState(() {
//         driverid = value;
//       });
//
//       // print("checkid===${driverid}");
//     });
//   }
//
//   Future<bool> _onBackPressed() async {
//     //Navigator.pop(context);
//     //Navigator.of(context).pop(true);
//     Navigator.of(context).pushReplacement(
//         MaterialPageRoute<Null>(builder: (BuildContext context) {
//       return new MyParcelListPage(tripid: widget.tripid);
//     }));
//     return true;
//   }
//
//
//
//   void getPostsData() async {
//     var APIURL = Uri.parse(
//         'http://votivetech.in/courier/webservice/api/getParcelDropLocationByDriverId');
//     Map mapeddate = {"driver_id": widget.driver_id};
//     Response response = await post(APIURL, body: mapeddate);
//     var data = jsonDecode(response.body);
//     print("APIURL>>>: ${APIURL}");
//     int status = data['status'];
//     List data1 = data['data'];
//     print("MapPageState: ${data1}");
//     List<dynamic> responseList = data1;
//     List<Widget> listItems = [];
//     responseList.forEach((post) {
//       TaskModel model = new TaskModel(
//           post["parcel_id"],
//           post["pic_up_location"],
//           post["drop_location"],
//           post["pickup_latitude"],
//           post["pickup_longitude"],
//           post["drop_latitude"],
//           post["drop_longitude"]);
//       listofTasks.add(model);
//       print("listofTasks>>>: ${listofTasks}");
//       print("model>>>: ${model}");
//
//       SOURCE_LOCATION=LatLng(double.parse(post["pickup_latitude"]), double.parse( post["pickup_longitude"]));
//       DEST_LOCATION=LatLng(double.parse(  post["drop_latitude"]), double.parse( post["drop_longitude"]));
//
//     });
//     setState(() {
//       itemsData = listItems;
//     });
//   }
//
// }
//
// class Utils {
//   static String mapStyles = '''[
//   {
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.icon",
//     "stylers": [
//       {
//         "visibility": "off"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.stroke",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "featureType": "administrative.land_parcel",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#bdbdbd"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#ffffff"
//       }
//     ]
//   },
//   {
//     "featureType": "road.arterial",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#dadada"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "featureType": "road.local",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.line",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.station",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#c9c9c9"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   }
// ]''';
//
//
// }
// class TaskModel {
//   String taskid;
//   String name;
//   String address;
//   String slatitude;
//   String dlatitude;
//   String slongitude;
//   String dlongitude;
//
//   TaskModel(this.taskid, this.name, this.address, this.slatitude,
//       this.slongitude, this.dlatitude, this.dlongitude);
// }