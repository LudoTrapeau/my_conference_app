import 'dart:async';
import 'dart:io';

import 'file:///C:/Users/ludovic.trapeau/Documents/my_team_app/events_app/lib/utils/sp_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppPreMain {
  static Future init(VoidCallback callback) async {
    WidgetsFlutterBinding.ensureInitialized();
    //Stetho.initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //SystemChrome.setEnabledSystemUIOverlays([]);
    await SpUtil.getInstance();

  }
}
