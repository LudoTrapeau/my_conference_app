import 'dart:async';
import 'dart:io';
import 'package:random_string/random_string.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:filter_list/filter_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_conference_app/screens/splash_page.dart';
import 'package:my_conference_app/screens/users_management.dart';
import 'package:my_conference_app/utils/const.dart';
import 'package:my_conference_app/utils/hexToColor.dart';
import 'package:my_conference_app/utils/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../events.dart';
import '../login.dart';
import '../profil_page.dart';
import '../utils/hexColor.dart';
import 'my_event_list.dart';

class EventsHomeWidget extends StatefulWidget {
  static const routeName = '/EventsHome';

  EventsHomeWidget(this.isConnect, this.userRule);

  bool isConnect;
  String userRule;

  @override
  _EventsHomeWidgetState createState() => _EventsHomeWidgetState();
}

class _EventsHomeWidgetState extends State<EventsHomeWidget> {
  _EventsHomeWidgetState();

  final eventNbPlacesController = TextEditingController();
  final eventTitleController = TextEditingController();
  final eventTypeController = TextEditingController();
  final eventDateController = TextEditingController();
  final eventTimeController = TextEditingController();
  final eventDurationController = TextEditingController();
  final eventPriceController = TextEditingController();
  final eventLocationController = TextEditingController();
  final eventAdressController = TextEditingController();
  String _ratingController;
  List<String> eventsTypeList = ["Conférence", "Séminaire"];
  final formatDay = DateFormat("yyyy-MM-dd");
  final formatTime = DateFormat("HH:mm");
  String role;
  final String CONSTANT_NAME = "nom";
  final String CONSTANT_TYPE = "type";
  final String CONSTANT_DATE = "date";
  final String CONSTANT_NBPLACES = "nbPlaces";
  final String CONSTANT_TIME = "time";
  final String CONSTANT_ID = "id";
  final String CONSTANT_LOCATION = "location";
  final String CONSTANT_DURATION = "duration";
  final String CONSTANT_PRICE = "price";
  final String CONSTANT_CREATEDBY = "createdBy";
  final String CONSTANT_ADRESS = "adress";
  final dbRefUser = FirebaseDatabase.instance.reference().child("users");
  final dbRefEvent = FirebaseDatabase.instance.reference().child("events");
  final dbRefParticipations = FirebaseDatabase.instance.reference().child("participations");
  final dbRefUsers = FirebaseDatabase.instance.reference().child("users");
  List eventsList = [];
  List participationsList = [];
  FirebaseUser user;
  bool isMapView = false;
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(46.313762, 2.827367);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  List<String> countList = [
    "Conférence",
    "Séminaire",
  ];
  List<String> selectedCountList = [];
  String location;

  @override
  Future<void> initState() {
    super.initState();
    someMethod();
    if (widget.userRule != null) print("userRule " + widget.userRule);
    getActuallyUser();
    getMarkers();
    PaystackPlugin.initialize(publicKey: "pk_test");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Prochaines conférences"),
          backgroundColor: HexColor("#BC1F32"),
        ),
        body: isMapView
            ? Stack(
                children: <Widget>[
                  FutureBuilder(
                      future: getFuture(),
                      builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          eventsList.clear();
                          Map<dynamic, dynamic> values = snapshot.data.value;
                          if (values != null) {
                            values.forEach((key, values) {
                              MyEvent event = new MyEvent(
                                  id: key.toString(),
                                  createdBy: values[CONSTANT_CREATEDBY],
                                  date: DateTime.parse(values[CONSTANT_DATE]),
                                  duration: values[CONSTANT_DURATION],
                                  location: values[CONSTANT_LOCATION],
                                  placesNumber: values[CONSTANT_NBPLACES],
                                  title: values[CONSTANT_NAME],
                                  price: values[CONSTANT_PRICE],
                                  type: "values[CONSTANT_TYPE]",
                                  time: values[CONSTANT_TIME]);
                              eventsList.add(event);
                            });

                            for (int i = 0; i < eventsList.length; i++) {
                              String lat = eventsList[i].location.toString().split(",")[0];
                              String lng = eventsList[i].location.toString().split(",")[1];
                              _markers.add(Marker(
                                // This marker id can be anything that uniquely identifies each marker.
                                markerId: MarkerId(eventsList[i].location.toString()),
                                position: LatLng(double.parse(lat), double.parse(lng)),
                                infoWindow: InfoWindow(
                                    //title: eventsList[i].type.toString(),
                                    snippet: eventsList[i].date.toString(),
                                    onTap: () {
                                      //showEventDetail(context, eventsList[i]);
                                      print("TAP ON MARKER " + eventsList[i].duration.toString());
                                      //testAlert(context);
                                    }),
                                icon: BitmapDescriptor.defaultMarker,
                              ));
                            }
                          }
                          //}

                        } else {
                          return Container();
                        }
                        return GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 5.0,
                          ),
                          mapType: _currentMapType,
                          markers: _markers,
                          onCameraMove: _onCameraMove,
                        );
                      }),
                  user != null
                      ? FutureBuilder(
                          future: dbRefUser.once(),
                          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              eventsList.clear();
                              Map<dynamic, dynamic> values = snapshot.data.value;

                              if (values != null) {
                                values.forEach((key, values) {
                                  if (values["email"].toString() == user.email) {
                                    print("VALUUUUES " + values["role"].toString());
                                    role = values["role"];
                                  }
                                  ;
                                });
                              }
                              return Container();
                              //}

                            } else {
                              return Container();
                            }
                          })
                      : Container(),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage('https://img.freepik.com/vecteurs-libre/elegant-fond-degrade_1340-3947.jpg?size=338&ext=jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      child: FutureBuilder(
                          future: getFuture(),
                          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              eventsList.clear();
                              Map<dynamic, dynamic> values = snapshot.data.value;
                              if (values != null) {
                                values.forEach((key, values) {
                                  DateTime eventDate = DateTime.parse(values['date'].toString());
                                  final date2 = DateTime.now();
                                  final isAfter = date2.isBefore(eventDate);

                                  // If event is programming after today date
                                  if (isAfter) eventsList.add(values);
                                });
                              }
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 350,
                                    child: ListView.builder(
                                        itemCount: eventsList.length,
                                        itemBuilder: (BuildContext ctxt, int index) {
                                          print("event id " + eventsList[index].toString());
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 8,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: new Card(
                                                  shape: BeveledRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  elevation: 5,
                                                  child: Column(
                                                    children: [
                                                      new Container(
                                                        color: Color(0xffFFFFFF),
                                                        child: Padding(
                                                          padding: EdgeInsets.only(bottom: 20.0),
                                                          child: new Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                              Center(
                                                                child: Padding(
                                                                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                    child: new Text(
                                                                      eventsList[index]['nom'],
                                                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                                                    )),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: 180,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                        child: new Row(
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          children: <Widget>[
                                                                            new Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.calendar_today,
                                                                                      color: Colors.green,
                                                                                      size: 25.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: new Text(
                                                                                        eventsList[index]['date'],
                                                                                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                      child: new Row(
                                                                        mainAxisSize: MainAxisSize.max,
                                                                        children: <Widget>[
                                                                          new Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.access_time,
                                                                                    color: Colors.green,
                                                                                    size: 25.0,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: new Text(
                                                                                      eventsList[index]['time'],
                                                                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: 180,
                                                                    child: Padding(
                                                                        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                        child: new Row(
                                                                          mainAxisSize: MainAxisSize.max,
                                                                          children: <Widget>[
                                                                            new Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: <Widget>[
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.group,
                                                                                      color: Colors.green,
                                                                                      size: 25.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: new Text(
                                                                                        eventsList[index]['nbPlaces'],
                                                                                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                      child: new Row(
                                                                        mainAxisSize: MainAxisSize.max,
                                                                        children: <Widget>[
                                                                          new Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Row(
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.euro_symbol,
                                                                                    color: Colors.green,
                                                                                    size: 25.0,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: new Text(
                                                                                      eventsList[index]['price'],
                                                                                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )),
                                                                ],
                                                              ),
                                                              Padding(
                                                                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                  child: new Row(
                                                                    mainAxisSize: MainAxisSize.max,
                                                                    children: <Widget>[
                                                                      Icon(
                                                                        Icons.timer,
                                                                        color: Colors.green,
                                                                        size: 25.0,
                                                                      ),
                                                                      new Flexible(
                                                                        child: new Text(
                                                                          eventsList[index]['duration'] + " min",
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                              Padding(
                                                                  padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                                                                  child: new Row(
                                                                    mainAxisSize: MainAxisSize.max,
                                                                    children: <Widget>[
                                                                      Icon(
                                                                        Icons.location_on,
                                                                        color: Colors.green,
                                                                        size: 25.0,
                                                                      ),
                                                                      new Flexible(
                                                                        child: new Text(
                                                                          eventsList[index]['adress'],
                                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                              /*
                                                      ExpansionTile(
                                                        title: Text(
                                                          "...",
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                        children: <Widget>[
                                                          ListTile(
                                                            title: Row(
                                                              children: [
                                                                Icon(Icons.timer,
                                                                  color: Colors.green,
                                                                  size: 30.0),
                                                                Text(
                                                                    eventsList[index]['duration'] + " min"
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),*/
                                                              Center(
                                                                child: RaisedButton(
                                                                  textColor: Colors.white,
                                                                  color: Colors.red,
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      dbRefParticipations
                                                                          .push()
                                                                          .set({"email": user.email, "eventId": eventsList[index]['id']});
                                                                    });
                                                                    chargeCard();
                                                                  },
                                                                  child: const Text('Participer', style: TextStyle(fontSize: 20)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              );
                              //}

                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FlatButton(
                          height: 50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          color: Colors.black.withOpacity(0.8),
                          splashColor: Colors.black26,
                          onPressed: () {
                            _openFilterDialog();
                          },
                          child: Text(
                            'Filtrer',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _createHeader(),
                Column(
                  children: <Widget>[
                    _createDrawerItem(
                        icon: Icons.home,
                        text: 'Home',
                        isHome: true,
                        isLogin: false,
                        isDeconnect: false,
                        isUsersManagement: false,
                        isProfilPage: false,
                        isEventList: false),
                    Divider()
                  ],
                ),
                widget.isConnect
                    ? Column(
                        children: <Widget>[
                          _createDrawerItem(
                              icon: Icons.account_circle, text: 'Mon profil', isLogin: false, isHome: false, isProfilPage: true, isEventList: false),
                          Divider()
                        ],
                      )
                    : Container(),
                widget.isConnect
                    ? Column(
                        children: <Widget>[
                          _createDrawerItem(
                              icon: Icons.event,
                              text: 'Mes évènements',
                              isLogin: false,
                              isHome: false,
                              isProfilPage: false,
                              isDeconnect: false,
                              isEventList: true,
                              isUsersManagement: false),
                          Divider()
                        ],
                      )
                    : Container(),
                !widget.isConnect
                    ? Column(
                        children: <Widget>[
                          _createDrawerItem(
                              icon: Icons.account_circle,
                              text: "S'inscrire",
                              isLogin: false,
                              isHome: false,
                              isProfilPage: false,
                              isDeconnect: false,
                              isUsersManagement: true,
                              isEventList: false),
                          Divider(),
                        ],
                      )
                    : Container(),
                widget.isConnect
                    ? Container()
                    : Column(
                        children: <Widget>[
                          _createDrawerItem(
                              icon: Icons.account_circle,
                              text: 'Se connecter',
                              isLogin: true,
                              isHome: false,
                              isProfilPage: false,
                              isDeconnect: false,
                              isUsersManagement: false,
                              isEventList: false),
                          Divider(),
                        ],
                      ),
                widget.isConnect
                    ? Column(
                        children: [
                          _createDrawerItem(
                              icon: Icons.account_circle,
                              text: 'Se déconnecter',
                              isLogin: false,
                              isHome: false,
                              isProfilPage: false,
                              isDeconnect: true,
                              isUsersManagement: true,
                              isEventList: false),
                          Divider()
                        ],
                      )
                    : Container(),
                ListTile(
                  title: Text('0.0.1'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: widget.isConnect && (widget.userRule == "admin" || widget.userRule == "client")
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new FloatingActionButton(
                    heroTag: "btn1",
                    tooltip: 'Add',
                    child: const Icon(Icons.library_add),
                    onPressed: () {
                      eventCreationModal(context);
                    },
                  ),
                  new FloatingActionButton(
                    heroTag: "btn2",
                    tooltip: 'View',
                    child: Icon(!isMapView ? Icons.map : Icons.list),
                    onPressed: () {
                      setState(() {
                        isMapView = !isMapView;
                      });
                    },
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new FloatingActionButton(
                    heroTag: "btn2",
                    tooltip: 'View',
                    child: Icon(!isMapView ? Icons.map : Icons.list),
                    onPressed: () {
                      setState(() {
                        isMapView = !isMapView;
                      });
                    },
                  )
                ],
              ));
  }

  someMethod() async {
    user = await FirebaseAuth.instance.currentUser();
    print(user.email);
  }

  Future<DataSnapshot> getFuture() async {
    if (selectedCountList.length == 0) {
      return dbRefEvent.once();
    } else {
      if (selectedCountList.length == 1) return dbRefEvent.orderByChild("type").equalTo(selectedCountList[0]).once();
    }
  }

  getActuallyUser() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  getMarkers() async {
    for (int i = 0; i < eventsList.length; i++) {
      _markers.add(Marker(
        onTap: () {
          print("TEST 2 ");
        },
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(LatLng(double.parse(eventsList[i].location.split(",")[0]), double.parse(eventsList[i].location.split(",")[1])).toString()),
        position: LatLng(double.parse(eventsList[i].location.split(",")[0]), double.parse(eventsList[i].location.split(",")[1])),
        infoWindow: InfoWindow(
          title: eventsList[i].title,
          snippet: eventsList[i].type,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
  }

  void _openFilterDialog() async {
    await FilterListDialog.display(context,
        allTextList: countList,
        allResetButonColor: HexColor("#BC1F32"),
        applyButonTextBackgroundColor: HexColor("#BC1F32"),
        closeIconColor: HexColor("#BC1F32"),
        selectedTextBackgroundColor: HexColor("#BC1F32"),
        height: 480,
        borderRadius: 20,
        headlineText: "Sélectionner un filtre",
        selectedTextList: selectedCountList, onApplyButtonClick: (list) {
      if (list != null) {
        setState(() {
          selectedCountList = List.from(list);
        });
        Navigator.pop(context);
      }
    });
  }

  void eventCreationModal(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Création d'un évènement"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextField(
              controller: eventTitleController,
              decoration: new InputDecoration(labelText: "Nom"), // Only numbers can be entered
            ),
            new DropdownButtonFormField<String>(
              decoration: new InputDecoration(labelText: "Type d'évènement"),
              value: _ratingController,
              items: ["Conférence", "Séminaire"]
                  .map((label) => DropdownMenuItem(
                        child: Text(label.toString()),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _ratingController = value;
                });
              },
            ),
            DateTimeField(
              controller: eventDateController,
              decoration: new InputDecoration(labelText: "Date"),
              format: formatDay,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context, firstDate: DateTime(1900), initialDate: currentValue ?? DateTime.now(), lastDate: DateTime(2100));
              },
            ),
            DateTimeField(
              controller: eventTimeController,
              decoration: new InputDecoration(labelText: "Horaire"),
              format: formatTime,
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.convert(time);
              },
            ),
            new TextField(
              controller: eventDurationController,
              decoration: new InputDecoration(labelText: "Durée (en min)"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly], // Only numbers can be entered
            ),
            new TextField(
              controller: eventNbPlacesController,
              decoration: new InputDecoration(labelText: "Nombre de places"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly], // Only numbers can be entered
            ),
            new TextField(
              controller: eventPriceController,
              decoration: new InputDecoration(labelText: "Prix"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly], // Only numbers can be entered
            ),
            new TextField(
              controller: eventAdressController,
              decoration: new InputDecoration(labelText: "Adresse"), // Only numbers can be entered
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () async {
            await getCoordonnatesByAdress(eventAdressController.text).then((value) {
              location = value;
              print("loc " + location);
            });
            if (eventTitleController.text.isNotEmpty ||
                eventNbPlacesController.text.isNotEmpty ||
                eventDateController.text.isNotEmpty ||
                eventDateController.text.isNotEmpty ||
                eventTimeController.text.isNotEmpty) {
              setState(() {
                dbRefEvent.push().set({
                  CONSTANT_NAME: eventTitleController.text,
                  CONSTANT_TYPE: _ratingController.toString(),
                  CONSTANT_NBPLACES: eventNbPlacesController.text,
                  CONSTANT_DATE: eventDateController.text,
                  CONSTANT_TIME: eventTimeController.text,
                  CONSTANT_ID: randomString(10),
                  CONSTANT_ADRESS: eventAdressController.text,
                  CONSTANT_LOCATION: location,
                  CONSTANT_DURATION: eventDurationController.text,
                  CONSTANT_PRICE: eventPriceController.text,
                  CONSTANT_CREATEDBY: user.email,
                });
              });
              eventTitleController.clear();
              eventNbPlacesController.clear();
              eventDateController.clear();
              eventTimeController.clear();
              eventAdressController.clear();
              eventDurationController.clear();
              eventPriceController.clear();
              Fluttertoast.showToast(msg: "Evènement créé");
              Navigator.pop(context);
            } else {
              Fluttertoast.showToast(msg: "Veuillez renseigner tous les champs");
            }
          },
        ),
        FlatButton(
          child: Text("Annuler"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<String> getCoordonnatesByAdress(String adress) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(adress);
    String result = addresses.first.coordinates.latitude.toString() + "," + addresses.first.coordinates.longitude.toString();
    return result;
  }

  chargeCard() async {
    Charge charge = Charge()
      ..amount = 10000
      ..reference = _getReference()
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = 'customer@email.com';
    CheckoutResponse response = await PaystackPlugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.status == true) {
      _showDialog();
    } else {
      _showErrorDialog();
    }
  }

  Future<String> fetchAdress(String id) async {
    String fetchedUser;
    Coordinates coordinates = new Coordinates(double.parse(id.split(",")[0]), double.parse(id.split(",")[1]));
    var adres = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = adres.first;
    print(coordinates.latitude.toString() + " " + coordinates.longitude.toString());
    return first.addressLine;
  }

  Dialog successDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_box,
                color: hexToColor("#41aa5e"),
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Payment has successfully',
                style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              Text(
                'been made',
                style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Your payment has been successfully",
                style: TextStyle(fontSize: 13),
              ),
              Text("processed.", style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return successDialog(context);
      },
    );
  }

  Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Container(
          height: 200,
          width: 400,
          child: Image.asset("assets/images/logo_transparent.png"),
        ));
  }

  Widget _createDrawerItem(
      {IconData icon,
      String text,
      GestureTapCallback onTap,
      bool isLogin,
      bool isHome,
      bool isProfilPage,
      bool isDeconnect,
      bool isUsersManagement,
      bool isEventList}) {
    return ListTile(
        title: Row(
          children: <Widget>[
            Icon(icon),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(text),
            )
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => isLogin
                      ? LoginScreen()
                      : (isHome
                          ? EventsHomeWidget(widget.isConnect, widget.userRule)
                          : (isProfilPage
                              ? ProfilPage(user, widget.userRule)
                              : (isDeconnect ? disconnect() : (isEventList ? EventsListWidget() : UsersManagementPage()))))));
        });
  }

  deleteStringToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constant.KEY_SHARED_PREF_ISCONNECTED, false);
  }

  disconnect() {
    FirebaseAuth.instance.signOut();
    deleteStringToSF();
    return SplashPage();
  }

  addMarker(Marker marker) async {
    _markers.add(marker);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
