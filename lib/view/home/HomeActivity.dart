/*
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kurier/view/home/RestaurantList.dart';
import 'package:kurier/view/home/AddTripList.dart';
import 'package:kurier/view/home/tab/ProfilePage.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import '../../utils/color.dart';

class GroceryHomePage extends StatefulWidget {
  static final String path = "lib/src/pages/grocery/ghome.dart";

  @override
  GroceryHomePageState createState() {
    return new GroceryHomePageState();
  }
}

class GroceryHomePageState extends State<GroceryHomePage> {
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
  void initState() {
    super.initState();
  }

  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    ListApp(),
    ProfilePage(),
  ];

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


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
     // onWillPop: _onBackPressed,
      child: new Scaffold(
       */
/* appBar: AppBar(
          title: Text('Home'),
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
        ),*//*

        body: _widgetOptions.elementAt(_selectedIndex),
   */
/*     bottomNavigationBar: BottomNavigationBar(
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
              icon: Icon(Icons.person),
              title: Text('CALENDAR'),
              activeIcon: Icon(
                FontAwesome.user,
                color: Colors.blue,
              ),
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),*//*

      ),
    );
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
      bottom: PreferredSize(
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(1.0)),
      // automaticallyImplyLeading: false,
      backgroundColor: kPrimaryColor,
      elevation: 0,
      title: Text(title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
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
*/
