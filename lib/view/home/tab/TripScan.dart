import 'dart:convert';

//import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/home/HomeActivity.dart';

import 'TripList.dart';
String driverid;
class TripScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<TripScanPage> {
  String tripid = "Not Yet Scanned";
  final SecureStorage secureStorage = SecureStorage();
  @override
  void initState() {
    // TODO: implement initState
    fetchdriverid();
    //_scanQR();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //padding: EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(),
          //mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          /*children: <Widget>[
            FlatButton(
              padding: EdgeInsets.all(15.0),
              onPressed: ()  {
                _scanQR();
              },
              child: Text(
                "Open Scanner",
                style:
                TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue, width: 3.0),
                  borderRadius: BorderRadius.circular(20.0)),
            )
          ],*/
        ),
      ),
    );
  }
  /*_scanQR() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        tripid = barcode;
        print(tripid);
        AcceptTrip(tripid,context);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          tripid = 'The user did not grant the camera permission!';
        });
      } else {
        setState((){
          tripid='Unknown error: $e';
        });
      }
    } on FormatException{
      setState((){
        tripid= 'null (User returned using the "back"-button before scanning anything. Result)';
        _onBackPressed();
      });
    } catch (e) {
      setState((){
        tripid= 'Unknown error: $e';
      });
    }
  }*/
  _onBackPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ListApp();
        },
      ),
    );
  }

  Future AcceptTrip(String driverid,BuildContext context) async {
    var APIURL = Uri.parse('http://votivetech.in/courier/webservice/api/assignDriver');
    Map mapeddate = {
      'trip_id': tripid,
      'driver_id': driverid,
    };
    print(mapeddate);
    Response response = await post(APIURL,body:mapeddate);
    var data = jsonDecode(response.body);
    int status= data['status'];
    print(status);
    print("DATA: ${status}");
    if(status==1){
     // List data1 = data['data'];
     // print("DATATrip: ${data1}");
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
          msg: "Something Went Wrong",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //    timeInSecForIos: 1,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }

  }
  fetchdriverid() async{
    secureStorage.readSecureData("driverid").then((value){
      setState((){
        driverid=value;
      });

      // print("checkid===${driverid}");
    });
  }
}
