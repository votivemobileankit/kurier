import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:provider/provider.dart';

import 'HomeActivity.dart';

class UploadImageDemo extends StatefulWidget {
  UploadImageDemo(this.parcel_id);

  final String parcel_id;

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadImageDemo> {
  var file;
  var file1;
  Future<File> fileArray;

  String note;
  String imageType;
  var serverReceiverPath =
      "https://votivetech.in/courier/webservice/api/parcelDelivered";

  Future<String> uploadImage(filename) async {
    var request = http.MultipartRequest('POST', Uri.parse(serverReceiverPath));
    request.fields['parcel_id'] = widget.parcel_id;
    request.fields['note'] = "note";
    request.files.add(await http.MultipartFile.fromPath('image', filename));
    var res = await request.send();
    print("widget.parcelid>>>: ${widget.parcel_id}");
    print("note>>>: ${note}");
    print("reasonPhrase>>>: ${res.reasonPhrase}");

    if (res.reasonPhrase == "OK") {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new ListApp();
      }));
    }
      return res.reasonPhrase;

  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: fileArray,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          file1 = snapshot.data;
          imageType = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            file != null
                ? showImage()
                : SizedBox(
                    width: 0.0,
                  ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  //color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(29),
                  //borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Parcel Note",
                    //labelText: "Email",
                    border: InputBorder.none,
                  ),
                  onSaved: (String value) {
                    note = value;
                  },
                )),
            SizedBox(
              height: 100.0,
            ),
            file != null
                ? RaisedButton(
                    child: Text("Upload Image"),
                    onPressed: () async {
                      var res = await uploadImage(file.path);
                      setState(() {
                        print(res);
                      });
                    },
                  )
                : SizedBox(
                    width: 50.0,
                  ),
            file == null
                ? RaisedButton(
                    child: Text("Open Gallery"),
                    onPressed: () async {
                      file = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                      file1 = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                      setState(() {});
                      // fileArray =
                      //     ImagePicker.platform.pickImage(source: ImageSource.gallery);
                    },
                  )
                : SizedBox(
                    width: 0.0,
                  )
          ],
        ),
      ),
    );
  }
}
