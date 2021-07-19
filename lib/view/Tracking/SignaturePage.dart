import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:kurier/view/home/uploadImage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

import 'NewMapScreen.dart';


class SignaturePage extends StatefulWidget {
  final String tripid;
  final String parcel_id;
  final String picklat;
  final String picklong;
  final String droplat;
  final String droplong;
  final String driver_id;


  SignaturePage(
      {this.tripid,
        this.parcel_id,
        this.picklat,
        this.picklong,
        this.droplat,
        this.droplong,
        this.driver_id});

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  SignatureController controller;

  @override
  void initState() {
    super.initState();

    controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.white,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Delivered Parcel'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return new NewMapScreen(
                            tripid: widget.tripid,
                            parcel_id: widget.parcel_id,
                            picklat: widget.picklat,
                            picklong: widget.picklong,
                            droplat: widget.droplat,
                            droplong: widget.droplong,
                            driver_id: widget.driver_id);
                      }));
            }));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBarOne("Deliverd "),
        body: Column(
          children: <Widget>[
            Signature(
              controller: controller,
              backgroundColor: Colors.black,
            ),
            buildButtons(context),
            buildSwapOrientation(),
          ],
        ),
      );

  Widget buildSwapOrientation() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final newOrientation =
            isPortrait ? Orientation.landscape : Orientation.portrait;

        controller.clear();
        setOrientation(newOrientation);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPortrait
                  ? Icons.screen_lock_portrait
                  : Icons.screen_lock_landscape,
              size: 40,
            ),
            const SizedBox(width: 12),
            Text(
              'Tap to change signature orientation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) => Container(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildCheck(context, widget.parcel_id),
            buildClear(),
          ],
        ),
      );

  Widget buildCheck(BuildContext context, String parcel_id) => IconButton(
        iconSize: 36,
        icon: Icon(Icons.check, color: Colors.green),
        onPressed: () async {
          if (controller.isNotEmpty) {
            final signature = await exportSignature();

            await /* Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignaturePreviewPage(
                  signature: signature, parcelid: parcelid),
            ));*/
            storeSignature(context, signature);

            controller.clear();
          }
        },
      );

  Widget buildClear() => IconButton(
        iconSize: 36,
        icon: Icon(Icons.clear, color: Colors.red),
        onPressed: () => controller.clear(),
      );

  Future<Uint8List> exportSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: controller.points,
    );

    final signature = await exportController.toPngBytes();
    exportController.dispose();

    return signature;
  }

  void setOrientation(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  Future storeSignature(BuildContext context, Uint8List signature) async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final time = DateTime.now().toIso8601String().replaceAll('.', ':');
    final name = 'signature_$time.png';
    final result = await ImageGallerySaver.saveImage(signature, name: name);
    final isSuccess = result['isSuccess'];

    print("isSuccess>>>>>>: ${isSuccess}");
    print("name>>>>>>: ${name}");

    if (isSuccess) {

     Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => UploadImageDemo(widget.parcel_id)));

      Fluttertoast.showToast(
          msg: "Saved to signature folder",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to save signature",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color(0xff2199c7),
          textColor: Colors.red,
          fontSize: 16.0);
    }
  }
}
