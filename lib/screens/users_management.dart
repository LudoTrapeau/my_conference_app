import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_conference_app/screens/events_home.dart';

import '../utils/hexColor.dart';

class UsersManagementPage extends StatefulWidget {
  static const routeName = '/UsersManagementPage';
  UsersManagementPage();

  @override
  UsersManagementPageState createState() => UsersManagementPageState();
}

class UsersManagementPageState extends State<UsersManagementPage> with SingleTickerProviderStateMixin {
  int _value = 1;
  final _auth = FirebaseAuth.instance;
  String role = "admin";
  String email;
  String password;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.reference().child("users");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Inscription"),
          backgroundColor: HexColor("#BC1F32"),
        ),
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    height: 170.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: new ExactAssetImage('assets/images/as.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ],
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  new Container(
                    color: Color(0xffFFFFFF),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Création d\'un utilisateur',
                                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Divider(),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Adresse mail',
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      decoration: const InputDecoration(
                                        hintText: "Entrez votre email",
                                      ),
                                      enabled: true,
                                      autofocus: false,
                                      controller: emailController,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Mot de passe',
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      decoration: const InputDecoration(
                                        hintText: "Entrez votre mot de passe",
                                      ),
                                      enabled: true,
                                      autofocus: false,
                                      controller: passwordController,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Confirmez votre mot de passe',
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextField(
                                      decoration: const InputDecoration(
                                        hintText: "Entrez votre mot de passe",
                                      ),
                                      enabled: true,
                                      autofocus: false,
                                      controller: passwordConfirmationController,
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Rôle',
                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 25.0, right: 25.0),
                            child: DropdownButton(
                                value: _value,
                                items: [
                                  DropdownMenuItem(
                                    child: Text("admin"),
                                    value: 1,
                                    onTap: () {
                                      role = "admin";
                                    },
                                  ),
                                  DropdownMenuItem(
                                    child: Text("client"),
                                    value: 2,
                                    onTap: () {
                                      role = "client";
                                    },
                                  ),
                                  DropdownMenuItem(
                                    child: Text("utilisateur"),
                                    value: 3,
                                    onTap: () {
                                      role = "utilisateur";
                                    },
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _value = value;
                                    print("VALUE " + value.toString());
                                  });
                                }),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Material(
                                color: Colors.red[800],
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                elevation: 5.0,
                                child: MaterialButton(
                                  onPressed: () async {
                                    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
                                      print("Veuillez remplir tous les champs");
                                    } else if (passwordController.text != passwordConfirmationController.text) {
                                      print("Les deux mots de passe ne sont pas identiques");
                                    } else {
                                      userCreation(emailController.text, role, passwordController.text);
                                    }
                                  },
                                  minWidth: 200.0,
                                  height: 42.0,
                                  child: Text(
                                    "Ajouter",
                                    style: new TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  userCreation(String email, String role, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    dbRef.push().set({
      "email": emailController.text,
      "role": role,
    });
    emailController.clear();
    passwordController.clear();
    passwordConfirmationController.clear();
    Fluttertoast.showToast(
        msg: "Votre compte a été créé",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        fontSize: 16.0);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => EventsHomeWidget(true, role)));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    super.dispose();
  }
}
