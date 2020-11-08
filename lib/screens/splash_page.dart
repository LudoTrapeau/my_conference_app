import 'dart:async';
import 'dart:io';

import 'package:my_conference_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_conference_app/screens/events_home.dart';
import 'package:my_conference_app/utils/const.dart';
//import 'package:my_conference_app/screens/events_home.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login.dart';
import '../utils/hexColor.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/SplashPage';

  bool isConnected;

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Widget _nextScreen;

  bool isConnected;
  String userRule;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid)
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    WidgetsBinding.instance.addPostFrameCallback((_){
      getConnexion().then((value){
        isConnected = value;
        getUserRule();
        init(isConnected);
      });
    });


  }

  getUserRule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    userRule = prefs.getString('role') ?? "";
    print("role " + userRule);
  }

  Future<bool> getConnexion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool(Constant.KEY_SHARED_PREF_ISCONNECTED) != null && prefs.getBool(Constant.KEY_SHARED_PREF_ISCONNECTED)){
      this.isConnected = true;
      return true;
    }else{
      this.isConnected = false;
      return false;
    }
  }

  init(bool isConnected) async {
    isConnected ? _nextScreen = EventsHomeWidget(true, userRule) : _nextScreen = EventsHomeWidget(false, "");
    new Timer(Duration(seconds: 3), onDoneLoading);
  }


  onDoneLoading() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => _nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/logo_transparent.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: new LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 50,
                animation: true,
                lineHeight: 20.0,
                animationDuration: 2500,
                percent: 1,
                center: Text("Chargement"),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: HexColor("#BC1F32"),
              ),
            ),

          ],
        ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }
}
