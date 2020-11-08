import 'package:my_conference_app/login.dart';
import 'package:my_conference_app/profil_page.dart';
import 'package:my_conference_app/screens/events_home.dart';
import 'package:my_conference_app/screens/my_event_list.dart';
import 'package:my_conference_app/screens/splash_page.dart';
import 'package:my_conference_app/screens/users_management.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
    case EventsHomeWidget.routeName:
    return MaterialPageRoute(builder: (_) => EventsHomeWidget(true, ""));
      case SplashPage.routeName:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case ProfilPage.routeName:
        return MaterialPageRoute(builder: (_) => ProfilPage(null, ""));
      case UsersManagementPage.routeName:
        return MaterialPageRoute(builder: (_) => UsersManagementPage());
      case EventsListWidget.routeName:
        return MaterialPageRoute(builder: (_) => EventsListWidget());
      default:
        return MaterialPageRoute(builder: (_) => SplashPage());
    }
  }
}
