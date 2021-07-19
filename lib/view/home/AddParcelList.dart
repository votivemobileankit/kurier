import 'dart:convert';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kurier/model/AddressSearch.dart';
import 'package:kurier/model/Place.dart';
import 'package:kurier/view/home/AddTripList.dart';
import 'package:kurier/view/home/HomeActivity.dart';
import 'package:kurier/view/home/tab/TripList.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:http/http.dart';

import 'package:kurier/constants/rounded_button.dart';
import 'package:kurier/session/SecureStorage.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';

import 'RestaurantList.dart';

const kGoogleApiKey = "AIzaSyB6jpjQRZn8vu59ElER36Q2LaxptdAghaA";

String restaurant_id;
String driver_id;
String trip_id;
String country_id;
String country_name;
String region_id;
String City_name;
String City_id;

class AddParcelList extends StatefulWidget {
  final String tripid;
  final String driver_id;

  AddParcelList({
    this.tripid,
    this.driver_id,
  });

  @override
  ParcelData createState() => ParcelData();
}

class CountryList {
  String country_id;
  String name;
  String code;
  String isdcode;

  CountryList(this.country_id, this.name, this.code, this.isdcode);
}

class StateList {
  String region_id;
  String country_id;
  String name;

  StateList(this.region_id, this.country_id, this.name);
}

class CityList {
  String city_id;
  String region_id;
  String country_id;
  String name;

  CityList(this.city_id, this.region_id, this.country_id, this.name);
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class ParcelData extends State<AddParcelList> {
  final SecureStorage secureStorage = SecureStorage();
  final _controller = TextEditingController();
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  List<Widget> itemsData = [];
  List<CountryList> mCountryList = new List<CountryList>();

  List<Widget> itemsData1 = [];
  List<StateList> mStateList = new List<StateList>();

  List<Widget> itemsData2 = [];
  List<CityList> mCityList = new List<CityList>();

  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();
  final focus6 = FocusNode();
  final focus7 = FocusNode();
  final focus8 = FocusNode();

  List<DropdownMenuItem<CountryList>> _dropdownMenuItems;
  CountryList _selectedCompany;

  onChangeDropdownItem(CountryList selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
      country_id = _selectedCompany.country_id;
      getStateList();
    });
  }

  List<DropdownMenuItem<StateList>> _dropdownStateItems;
  StateList _selectedState;

  onChangeDropdownStateItem(StateList state) {
    setState(() {
      _selectedState = state;
      region_id = _selectedState.region_id;
      getCityList();
    });
  }

  List<DropdownMenuItem<CityList>> _dropdownCityItems;
  CityList _selectedCity;

  onChangeDropdownCityItem(CityList city) {
    setState(() {
      _selectedCity = city;
      City_id = _selectedCity.city_id;
      City_name = _selectedCity.name;
    });
  }

  int _ocrCamera = FlutterMobileVision.CAMERA_BACK;
  String customerName;
  String customerLastName;
  String mobile;

  String parcelInformation;
  String parcelAddress;
  String ZIP_Code;

  @override
  void initState() {
    super.initState();

    getStateList();

    secureStorage.readSecureData("restaurant_id").then((value) {
      restaurant_id = value;
      print("restaurant_id: ${restaurant_id}");
    });

    secureStorage.readSecureData("driverid").then((value1) {
      driver_id = value1;
      print("driverid: ${driver_id}");
    });

    trip_id = widget.tripid;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
           appBar: _buildAppBarOne("Add Trip"),
            body: new Center(
                child: SingleChildScrollView(
              reverse: true,
              child: Form(
                key: globalKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 200 * 0.03),
                    Row(children: <Widget>[
                      buildCustomername(context),
/*                      IconButton(
                          icon: new Icon(Icons.scanner), onPressed: _nameScan)*/
                    ]),
                    Row(children: <Widget>[
                      buildCustomerfullname(context),
                      //IconButton(
                         // icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),
                    Row(children: <Widget>[
                      buildphone(context),
                     // IconButton(
                         // icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),

                    /*buildCountry(context),*/

                    Row(children: <Widget>[
                      buildState(context),
                     // IconButton(
                         // icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),
                    Row(children: <Widget>[
                      buildCity(context),
                      //IconButton(
                          //icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),
                    Row(children: <Widget>[
                      buildZipCode(context),
                     // IconButton(
                          //icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),
                    Row(children: <Widget>[
                      buildParcelAddress(context),
                     // IconButton(
                         // icon: new Icon(Icons.scanner), onPressed: _nameScan)
                    ]),
                    buildParcelInformation(context),
                    RoundedButton(
                      text: "Add Parcel",
                      press: () {
                        if (!globalKey.currentState.validate()) {
                          return;
                        }
                        globalKey.currentState.save();

                        if (restaurant_id == null) {
                          Fluttertoast.showToast(
                              msg: "Please Select First Restaurant",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              //    timeInSecForIos: 1,
                              backgroundColor: Color(0xff2199c7),
                              textColor: Colors.red,
                              fontSize: 16.0);

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantList()));
                        } else {
                          RegisterUser(context);
                        }

                        print("RegisterUser111: ${RegisterUser}");
                      },
                    ),
                    SizedBox(height: 50 * 0.05),
                  ],
                ),
              ),
            ))));
  }

  Widget _buildAppBarOne(String title) {
    return AppBar(
        title: new Text('Add Parcel'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => ListApp());
              Navigator.pushReplacement(context, route);
            }));
  }

  Widget buildCustomername(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Customer Name",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Customer Name is required';
            }
          },
          onSaved: (String value) {
            customerName = value;
          },
        ));
  }

  Widget buildCountry(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: DropdownButton(
          value: _selectedCompany,
          items: _dropdownMenuItems,
          onChanged: onChangeDropdownItem,
          onTap: getStateList,
        ));
  }

  Widget buildState(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: DropdownButton(
          value: _selectedState,
          items: _dropdownStateItems,
          onChanged: onChangeDropdownStateItem,
          onTap: getCityList,
        ));
  }

  Widget buildphone(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          focusNode: focus1,
          decoration: InputDecoration(
            icon: Icon(
              Icons.call,
            ),
            hintText: "Mobile",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus2);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Mobile is required';
            }
            if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value)) {
              return 'Please enter valid mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            mobile = value;
          },
        ));
  }

  Widget buildCity(BuildContext context) {
    //  Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: DropdownButton(
          value: _selectedCity,
          items: _dropdownCityItems,
          onChanged: onChangeDropdownCityItem,
        ));
  }

  Widget buildCustomerfullname(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Customer full Name",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus1);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Customer full name is required';
            }
          },
          onSaved: (String value) {
            customerLastName = value;
          },
        ));
  }

  Widget buildParcelInformation(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: 450 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.location_on,
            ),
            hintText: "Parcel information",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus4);
          },
          onSaved: (String value) {
            parcelInformation = value;
          },
        ));
  }

  Widget buildParcelAddress(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: 300 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextField(
          keyboardType: TextInputType.streetAddress,
          controller: _controller,
          readOnly: true,
          onTap: () async {
            // generate a new token here
            final sessionToken = Uuid().v4();
            final Suggestion result = await showSearch(
              context: context,
              delegate: AddressSearch(sessionToken),
            );
            // This will change the text displayed in the TextField
            if (result != null) {
              final placeDetails = await PlaceApiProvider(sessionToken)
                  .getPlaceDetailFromId(result.placeId);
              setState(() {
                _controller.text = result.description;
                _streetNumber = placeDetails.streetNumber;
                _street = placeDetails.street;
                _city = placeDetails.city;
                _zipCode = placeDetails.zipCode;
              });
            }
          },
          decoration: InputDecoration(
            icon: Icon(
              Icons.location_on,
            ),
            hintText: "Enter your shipping address",
            border: InputBorder.none,
          ),
        ));
  }

/*
  Widget buildphone(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
          keyboardType: TextInputType.phone,
          focusNode: focus5,
          decoration: InputDecoration(
            icon: Icon(
              Icons.call,
            ),
            hintText: "Mobile",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus5);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Mobile is required';
            }
            if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value)) {
              return 'Please enter valid mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            mobile = value;
          },
        ));
  }
*/

  Widget buildZipCode(BuildContext context) {
    //   Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: 200 * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            icon: Icon(
              Icons.location_city,
            ),
            hintText: "Zip Code",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus7);
          },
          onSaved: (String value) {
            ZIP_Code = value;
          },
        ));
  }

  Future RegisterUser(BuildContext context) async {
    print("RegisterUser: ${RegisterUser}");

    DateTime dateToday =new DateTime.now();
    String date = dateToday.toString().substring(0,10);
    print(date);

    var APIURL = Uri.parse('https://votivetech.in/courier/webservice/api/addParcel');
    Map mapeddate = {
      'first_name': customerName,
      'last_name': customerLastName,
      'customer_number': mobile,
      'customer_zip_code': ZIP_Code,
      'customer_city': City_id,
      'customer_country': '210',
      'customer_state': region_id,
      /*  'customer_address': _controller.text,*/
      'driver_id': driver_id,
      'trip_id': trip_id,
      'date': date,
      'drop_location': _controller.text,
      'parcel_information': parcelInformation,
      'restaurant_id': restaurant_id,
    };

    print("parcel::: ${mapeddate}");

    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);

    print("addTrip: ${data}");
    print("mapeddate: ${mapeddate}");

    int status = data['status'];
    if (status == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new ListApp();
      }));
    }
  }

  List<DropdownMenuItem<CountryList>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<CountryList>> items = List();
    for (CountryList company in companies) {
      items.add(
        DropdownMenuItem(
          value: company,
          child: Text(company.name),
          onTap: getCityList,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<StateList>> buildDropdownMenuIStatetems(
      List companies) {
    List<DropdownMenuItem<StateList>> items = List();
    for (StateList state in companies) {
      items.add(
        DropdownMenuItem(
          value: state,
          child: Text(state.name),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<CityList>> buildDropdownMenuICityems(List companies) {
    List<DropdownMenuItem<CityList>> items = List();
    for (CityList state in companies) {
      items.add(
        DropdownMenuItem(
          value: state,
          child: Text(state.name),
        ),
      );
    }
    return items;
  }

  Future<Null> _nameScan() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        camera: _ocrCamera,
        waitTap: true,
      );

      setState(() {
        customerName = texts[0].value;
      });
    } on Exception {
      texts.add(OcrText('Failed to recognize text'));
    }
  }

  void getCountryList() async {
    print("getPostsData>>>: ${getCountryList}");

    var APIURL = Uri.parse(
        'https://votivetech.in/courier/webservice/api/getCountryList');

    Response response = await get(APIURL);
    var data = jsonDecode(response.body);

    int status = data['status'];
    List data1 = data['data'];
    List<dynamic> responseList = data1;
    List<Widget> listItems = [];

    print("responseList>>>: ${responseList}");
    print("MapPageState: ${data1}");

    responseList.forEach((post) {
      CountryList model = new CountryList(
          post["country_id"], post["name"], post["code"], post["isdcode"]);

      mCountryList.add(model);

      print("listofTasks>>>: ${mCountryList.length}");
      print("model>>>: ${model}");

      _dropdownMenuItems = buildDropdownMenuItems(mCountryList);
      _selectedCompany = _dropdownMenuItems[0].value;
    });

    country_id = _selectedCompany.country_id;
    getStateList();

    print("listofTasks>>>: ${mCountryList.length}");
    setState(() {
      itemsData = listItems;
    });
  }

  void getStateList() async {
    print("getPostsData>>>: ${getStateList}");

    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/getStateList');
    Map mapeddate = {
      "country_id": '210',
    };
    print("APIURL>>>: ${APIURL}");
    print("mapeddate>>>: ${mapeddate}");

    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);

    int status = data['status'];
    List data1 = data['data'];
    List<dynamic> responseList = data1;
    List<Widget> listItems = [];

    print("responseList>>>: ${responseList}");
    print("MapPageState: ${data1}");

    responseList.forEach((post) {
      StateList model =
          new StateList(post["region_id"], post["country_id"], post["name"]);

      mStateList.add(model);

      print("listofTasks>>>: ${mStateList.length}");
      print("model>>>: ${model}");

      _dropdownStateItems = buildDropdownMenuIStatetems(mStateList);
      _selectedState = _dropdownStateItems[0].value;
    });
    region_id = _selectedState.region_id;
    getCityList();

    print("listofTasks>>>: ${mStateList.length}");
    setState(() {
      itemsData1 = listItems;
    });
  }

  void getCityList() async {
    print("getCityList>>>: ${getCityList}");

    var APIURL =
        Uri.parse('https://votivetech.in/courier/webservice/api/getCityList');
    Map mapeddate = {
      "region_id": region_id,
    };
    print("APIURL>>>: ${APIURL}");
    print("mapeddate>>>: ${mapeddate}");

    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);

    int status = data['status'];
    List data1 = data['data'];
    List<dynamic> responseList = data1;
    List<Widget> listItems = [];

    print("responseList>>>: ${responseList}");
    print("MapPageState: ${data1}");

    responseList.forEach((post) {
      CityList model = new CityList(
          post["city_id"], post["region_id"], post["country_id"], post["name"]);

      mCityList.add(model);

      print("listofTasks>>>: ${mCityList.length}");
      print("model>>>: ${model}");

      _dropdownCityItems = buildDropdownMenuICityems(mCityList);
      _selectedCity = _dropdownCityItems[0].value;
    });

    City_id = _selectedCity.city_id;

    print("listofTasks>>>: ${mCityList.length}");
    setState(() {
      itemsData1 = listItems;
    });
  }

  Future<bool> _onBackPressed() {
    Route route = MaterialPageRoute(builder: (context) => ListApp());
    Navigator.pushReplacement(context, route);
  }
}

/*class AddParcelBody extends StatelessWidget {
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  String customerName;
  String customerLastName;
  String mobile;
  String address;
  String parcelInformation;
  String parcelAddress;
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: globalKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
          SizedBox(height: size.height * 0.03),
          buildCustomername(context),
          buildCustomerfullname(context),
          buildphone(context),
          buildCustomerAddress(context),
          buildParcelInformation(context),
          // buildParcelAddress(context),


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
              child: TextField(
                keyboardType: TextInputType.name,
                controller: _controller,
                readOnly: true,
                onTap: () async {
                  // generate a new token here
                  final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      _controller.text = result.description;
                      _streetNumber = placeDetails.streetNumber;
                      _street = placeDetails.street;
                      _city = placeDetails.city;
                      _zipCode = placeDetails.zipCode;
                    });
                  }
                },
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.person,
                  ),
                  hintText: "Enter your shipping address",
                  border: InputBorder.none,
                ),
              ));
          RoundedButton(
          text: "Add Parcel",
          press: () {
            if (!globalKey.currentState.validate()) {
              return;
            }
            globalKey.currentState.save();
            CircularProgressIndicator();

            RegisterUser(context);
            print("RegisterUser111: ${RegisterUser}");
          },
        ),
        SizedBox(height: size.height * 0.05),
        ],
      ),
    ),)
    ,
    );
  }

  Widget buildCustomername(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
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
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Customer Name",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Customer Name is required';
            }
          },
          onSaved: (String value) {
            customerName = value;
          },
        ));
  }

  Widget buildCustomerfullname(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
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
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Customer Full Name",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus1);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Customer Full Name is required';
            }
          },
          onSaved: (String value) {
            customerLastName = value;
          },
        ));
  }

  Widget buildCustomerAddress(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
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
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Customer address",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus3);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Customer address is required';
            }
          },
          onSaved: (String value) {
            address = value;
          },
        ));
  }

  Widget buildParcelInformation(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
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
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Parcel information",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus3);
          },
          onSaved: (String value) {
            parcelInformation = value;
          },
        ));
  }

  Widget buildParcelAddress(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        width: size.width * 0.8,
        decoration: BoxDecoration(
          //color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(29),
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: TextField(
          keyboardType: TextInputType.name,
          controller: _controller,
          readOnly: true,
          onTap: () async {
            // generate a new token here
            final sessionToken = Uuid().v4();
            final Suggestion result = await showSearch(
              context: context,
              delegate: AddressSearch(sessionToken),
            );
            // This will change the text displayed in the TextField
            if (result != null) {
              final placeDetails = await PlaceApiProvider(sessionToken)
                  .getPlaceDetailFromId(result.placeId);
              setState(() {
                _controller.text = result.description;
                _streetNumber = placeDetails.streetNumber;
                _street = placeDetails.street;
                _city = placeDetails.city;
                _zipCode = placeDetails.zipCode;
              });
            }
          },
          decoration: InputDecoration(
            icon: Icon(
              Icons.person,
            ),
            hintText: "Enter your shipping address",
            border: InputBorder.none,
          ),
        ));
  }

  Widget buildphone(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
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
          keyboardType: TextInputType.phone,
          focusNode: focus2,
          decoration: InputDecoration(
            icon: Icon(
              Icons.call,
            ),
            hintText: "Mobile",
            border: InputBorder.none,
          ),
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focus2);
          },
          validator: (String value) {
            if (value.isEmpty) {
              return 'Mobile is required';
            }
            if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value)) {
              return 'Please enter valid mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            mobile = value;
          },
        ));
  }

  Future RegisterUser(BuildContext context) async {
    print("RegisterUser: ${RegisterUser}");
    var APIURL =
    Uri.parse('https://votivetech.in/courier/webservice/api/addParcel');
    Map mapeddate = {
      'first_name': customerName,
      'last_name': customerLastName,
      'customer_number': mobile,
      'customer_address': address,
      'driver_id': driver_id,
      'trip_id': trip_id,
      'drop_location': _controller.text,
      'parcel_information': parcelInformation,
      'restaurant_id': restaurant_id,
    };
    print("parcel::: ${mapeddate}");
    Response response = await post(APIURL, body: mapeddate);
    var data = jsonDecode(response.body);
    print("addTrip: ${data}");
    print("mapeddate: ${mapeddate}");

    int status = data['status'];
    if (status == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new ListApp();
      }));
    }
  }
}*/

void onError(PlacesAutocompleteResponse response) {
  homeScaffoldKey.currentState.showSnackBar(
    SnackBar(content: Text(response.errorMessage)),
  );
}

Mode _mode = Mode.overlay;

Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );
  }
}
