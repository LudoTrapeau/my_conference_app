
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/hexColor.dart';

class EventsListWidget extends StatefulWidget {
  static const routeName = '/MyEventList';
  EventsListWidget();

  @override
  _NewsListWidgetState createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<EventsListWidget> {
  _NewsListWidgetState();

  final dbRef = FirebaseDatabase.instance.reference().child("events");
  final dbRefParticipations = FirebaseDatabase.instance.reference().child("participations");
  List eventsList = [];
  List participationsList = [];

  FirebaseUser user;


  @override
  void initState() {
    super.initState();
    someMethod();
  }

  someMethod() async {
    user = await FirebaseAuth.instance.currentUser();
    print(user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion de mes évènements"),
        backgroundColor: HexColor("#BC1F32"),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
              future: dbRefParticipations.once(),
              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.hasData) {
                  participationsList.clear();
                  Map<dynamic, dynamic> values = snapshot.data.value;
                  if (values != null) {
                    values.forEach((key, values) {
                      if (values["email"].toString() == user.email) participationsList.add(values);
                    });
                  }
                  return Container(
                    child: ListView.builder(
                        itemCount: participationsList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          //getDataByEvent(true, participationsList[index]['eventId']);
                          return FutureBuilder(
                              future: dbRef.orderByChild("id").equalTo(participationsList[index]["eventId"].toString()).once(),
                              builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                                if (snapshot.hasData || snapshot.data!=null) {
                                  eventsList.clear();
                                  Map<dynamic, dynamic> values = snapshot.data.value;
                                  String nom;
                                  String date;
                                  String time;
                                  String adress;
                                  if (values != null) {
                                    values.forEach((key, values) {
                                      nom = values["nom"];
                                      date = values["date"];
                                      time = values["time"];
                                      adress = values["adress"];
                                    });
                                    return Card(
                                      child: Column(
                                        children: [
                                          Text(nom, style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(date),
                                          Text(time),
                                          Text(adress)
                                        ],
                                      ),
                                    );
                                  }else{
                                    return Container();
                                  }

                                  //}

                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              });




                        }),
                  );
                  //}

                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ],
      ),
    );
  }

  getDataByEvent(bool isUserIsRegisteredForThisEvent, String eventId) async{
    return FutureBuilder(
      future: dbRef.once(),
      builder:(context, AsyncSnapshot<DataSnapshot> snapshot) {
        if(snapshot.hasData){
          if(isUserIsRegisteredForThisEvent){
            Map<dynamic, dynamic> values = snapshot.data.value;
            if (values != null) {
              values.forEach((key, values) {
                if (values["id"].toString() == eventId){
                  return Card(
                    child: Column(
                      children: [
                        Text(values["nom"]),
                        Text(values["date"]),
                        Text(values["time"])
                      ],
                    ),
                  );
                }
              });
            }
          }else{
            return Text("Vous ne vous êtes inscrits à aucun event");
          }
        }else{
          return Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Column(
              children: [
              Text("")
          ],
        ),);
      }
    );
  }

}
