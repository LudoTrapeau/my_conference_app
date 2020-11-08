import 'dart:async';
import 'dart:io';

import 'package:my_conference_app/app_pre_main.dart';
import 'package:my_conference_app/app_route_generator.dart';
import 'file:///C:/Users/ludovic.trapeau/Documents/my_conference_app/lib/screens/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  AppPreMain.init(() {
    runApp(MyApp());
  });
  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    print('Zone caught an $error');
    print('Zone caught an $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''),
        const Locale.fromSubtags(languageCode: 'fr'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
      title: "MyConferenceApp",
      initialRoute: SplashPage.routeName,
      onGenerateRoute: AppRouteGenerator.generateRoute,
    );
  }
}

