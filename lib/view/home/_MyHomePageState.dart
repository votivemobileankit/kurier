

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return new _MyHomePageState();
  }
}


class _MyHomePageState extends State<MyHomePage> {

  ProgressHUD _progressHUD;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      text: 'Loading...',
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('ProgressHUD Demo'),
        ),
        body: new Stack(
          children: <Widget>[
            new Text(
                'A clean and lightweight progress HUD for your Flutter app'),
            _progressHUD,
            new Positioned(
                child: new FlatButton(
                    onPressed: dismissProgressHUD,
                    child: new Text(_loading ? "Dismiss" : "Show")),
                bottom: 30.0,
                right: 10.0),

            Positioned(
              top: 48.0,
              left: 10.0,
              right: 10.0,
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "New York",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )

    );
  }


}