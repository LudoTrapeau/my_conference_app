
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_conference_app/screens/events_home.dart';
import 'package:my_conference_app/utils/const.dart';
import 'package:my_conference_app/utils/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
  static const routeName = '/LoginPage';
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final dbRef = FirebaseDatabase.instance.reference().child("users");
  FirebaseUser user;
  String role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Wrap(
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(
                      side: new BorderSide(
                          color: Colors.grey,
                          width: 2.0
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 48.0,
                      ),

                      Container(
                        height: 200,
                        width: 400,
                        child: Image.asset("assets/images/logo_transparent.png"),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 8,right: 8),
                              child: TextField(
                                style: new TextStyle(color: Colors.black),
                                controller: TextEditingController()..text = 'ludovic.trapeau@gmail.com',
                                onChanged: (value) {
                                  //Do something with the user input.
                                  email = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Entrez votre email',
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red[800], width: 1.0),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red[800], width: 2.0),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8,right: 8),
                              child: TextField(
                                controller: TextEditingController()..text = '0123456',
                                obscureText: true,
                                style: new TextStyle(color: Colors.black),
                                onChanged: (value) {
                                  //Do something with the user input.
                                  password = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Entrez votre mot de passe',
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red[800], width: 1.0),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red[800], width: 2.0),
                                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Material(
                                color: Colors.red[800],
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                elevation: 5.0,
                                child: MaterialButton(
                                  onPressed: () async {
                                    //Implement login functionality.
                                    if (email != null && password != null) {
                                      setState(() {
                                        showSpinner = true;
                                      });
                                      try {
                                        final logIn = await _auth.signInWithEmailAndPassword(email: email, password: password);
                                        if (logIn != null) {
                                          etUserRoleInSharedPref(email);
                                          CircularProgressIndicator();
                                          }
                                        showSpinner = false;
                                        Fluttertoast.showToast(
                                            msg: "Vous êtes connecté",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            textColor: Colors.black,
                                            fontSize: 16.0);
                                      } catch (e) {
                                        showSpinner = false;
                                        print(e);
                                        Fluttertoast.showToast(
                                            msg: "Mauvais login et/ou mot de passe",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Veuillez remplir toutes les cases",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  },
                                  minWidth: 200.0,
                                  height: 42.0,
                                  child: Text(
                                    "Se connecter",
                                    style: new TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  etUserRoleInSharedPref(String email) async{

    dbRef.once().then((value){
      Map<dynamic, dynamic> map = value.value;
      for(int i = 0; i < map.values.toList().length; i++){
        if(map.values.toList()[i]["email"] == email){
          role = map.values.toList()[i]["role"];
          print(role);
          addStringToSF(role);
          Navigator.push(context, MaterialPageRoute(builder: (context) => /*TestPage(true)*/EventsHomeWidget(true, role)));
          return role;
        }
      }
    });


  }

  addStringToSF(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('role', role);
  }


}
