import 'dart:convert';

//import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:kurier/view/home/HomeActivity.dart';

import 'TripList.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String driverid = "Not Yet Scanned";
  final SecureStorage secureStorage = SecureStorage();
  @override
  void initState() {
    // TODO: implement initState
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
        driverid = barcode;
        print(driverid);
        print("driverid>>>>1: ${driverid}");
        LoginUser(context);
        //showAlertDialog(context);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          driverid = 'The user did not grant the camera permission!';
          print("request>>>>1: ${driverid}");

        });
      } else {
        setState((){
          driverid='Unknown error: $e';
          print("request>>>>2: ${driverid}");
        });
      }
    } on FormatException{
      setState((){
        driverid= 'null (User returned using the "back"-button before scanning anything. Result)';
        print("request>>>>3: ${driverid}");
        _onBackPressed();
      });
    } catch (e) {
      setState((){
        driverid= 'Unknown error: $e';

        print("request>>>>4: ${driverid}");
      });
    }
  }*/
  /*showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = RaisedButton(
      child: Text("Reject"),
      textColor: Colors.white,
      color: Colors.red,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0)),
      onPressed:  () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GroceryHomePage();
            },
          ),
        );
      },
    );
    Widget continueButton = RaisedButton(
      child: Text("Accept"),
      textColor: Colors.white,
      color: Colors.green,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0)),
      onPressed:  () {
        secureStorage.readSecureData("driverid").then((value){
          driverid=value;
          AcceptTrip(driverid,context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are you Want to Accept the Trip or not?"),
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
  }*/
  _onBackPressed() {
    //Navigator.pop(context,true);
    SystemChannels.platform
        .invokeMethod('SystemNavigator.pop');
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return GroceryHomePage();
        },
      ),
    );*/
  }

  /*Future AcceptTrip(String driverid,BuildContext context) async {
    var APIURL = Uri.parse('https://votivetech.in/courier/webservice/api/assignDriver');
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
            return GroceryHomePage();
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

  }*/
  /*Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("YES"),
          ),
        ],
      ),
    ) ??
        false;
  }*/
  Future LoginUser(BuildContext context) async {
    var APIURL = Uri.parse('http://votivetech.in/courier/webservice/api/getDriverById');
    Map mapeddate = {
      'driver_id': driverid,
    };
    Response response = await post(APIURL,body:mapeddate);
    var data = jsonDecode(response.body);
    int status= data['status'];
    print("request>>>>: ${status}");
    print("APIURL>>>>: ${APIURL}");
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
        secureStorage.writeSecureData('image', data1[i]['driver_image']);
      };
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ListApp();
          },
        ),
      );
      /*Route route = MaterialPageRoute(builder: (context) => GroceryHomePage());
      Navigator.pushReplacement(context, route);*/
    }else{
      Fluttertoast.showToast(
          msg: "Unable to login please check email and password",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          //    timeInSecForIos: 1,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }

  }

}
