import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'ProfileScreen.dart';

class FirstRoute extends StatelessWidget {
  final UserDetails detailsUser;
  final int numUsers;

  FirstRoute({Key key, @required this.detailsUser, @required this.numUsers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        backgroundColor: Color.fromRGBO(23, 150, 50, 100),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
                'https://freepngimg.com/download/phoenix_tattoos/8-2-phoenix-tattoos-png-picture.png',
                fit: BoxFit.fill,
                color: Color.fromRGBO(255, 255, 255, 0.6),
                colorBlendMode: BlendMode.modulate),
            ButtonBar(
              buttonMinWidth: 400.00,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    // Navigate to the event creation screen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MainThird(detailsUser: detailsUser, numUsers: numUsers, listUsers: <String>["NULL"], curIndex: 0)),
                    );
                    //createRecord(databaseReference, detailsUser);
                    print("Moving to create record page.");
                  },
                  child: Text('Create Event'),
                ),
                RaisedButton(
                  onPressed: () {
                    // Navigate to the event cancellation screen.
                  },
                  child: Text('Cancel Event'),
                ),
                RaisedButton(
                  onPressed: () {
                    // Navigate to the event pending screen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondRoute()),
                    );
                  },
                  child: Text('Check Pending Event'),
                ),
                RaisedButton(
                  child: Text("Profile and Logout"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(detailsUser: detailsUser)),
                    );
                  },
                ),
              ],
            ),
          ],
        )));
  }
}

class SecondRoute extends StatelessWidget {
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              "Events:",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
              ),
              padding: const EdgeInsets.all(1.0),
              width: 300.00,
              child: RaisedButton(
                  child: Text(
                    document.documentID,
                    style: Theme.of(context).textTheme.display1,
                  ),
                  onPressed: () {
                    // Navigate to the actual event screen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FourthRoute(document.documentID, document)),
                    );
                  })),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Pending"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('events').snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) return const Text('Loading Data...');

            return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return _buildListItem(context, ds);
                });
          }),
    );
  }
}

class FourthRoute extends StatelessWidget {
  final String barName;
  final DocumentSnapshot ds;
  FourthRoute(this.barName, this.ds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(barName)),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text("Who's In?"),
              Text(ds.data['userEmail']),
              Text(ds.data['eventName']),
              Text(ds.data['location']),
              Text(ds.data['time']),
            ])));
  }
}

class MainThird extends StatefulWidget {
  final detailsUser;
  final numUsers;
  final listUsers;
  final curIndex;

  MainThird({this.detailsUser, this.numUsers, this.listUsers, this.curIndex});

  ThirdRoute createState() => ThirdRoute(detailsUser, numUsers, listUsers);
}

class ThirdRoute extends State<MainThird> {
  final eventName = TextEditingController();
  final location = TextEditingController();
  final time = TextEditingController();

  final databaseReference = Firestore.instance;
  final UserDetails detailsUser;
  var category;
  int currentIndex = 0;
  List<String> listUsers;
  int numUsers;
  ThirdRoute(this.detailsUser, this.numUsers, this.listUsers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sending out the call!"),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            TextFormField(
              controller: eventName,
              decoration:
                  InputDecoration(labelText: 'What\'s the event called?'),
            ),
            TextFormField(
              controller: location,
              decoration: InputDecoration(labelText: 'Where\'s it going down?'),
            ),
            TextFormField(
              controller: time,
              decoration: InputDecoration(labelText: 'When\'s it happening?'),
            ),
            Text(listUsers.toString()),
            RaisedButton(
              onPressed: () {
                // Navigate to the user selection screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DropDown(eventName, listUsers, currentIndex, detailsUser, numUsers)),
                );
                currentIndex += 1;
              },
              child: Text('Add Someone'),
            ),

            FloatingActionButton(onPressed: () {
              createRecord(databaseReference, detailsUser, eventName, location, time);
              print("the record has been created");
              for (var i = 0; i < listUsers.length; i++) addingUser(listUsers[i].toString(), eventName);
            }),

          ])),
    );
  }

  Future createRecord(
      databaseReference, detailsUser, eventName, location, time) async {
    await databaseReference
        .collection("events")
        .document(eventName.text)
        .setData({
      'userEmail': detailsUser.userEmail,
      'eventName': eventName.text,
      'location': location.text,
      'time': time.text,
    });
  }

  Future addUser(
      username, eventName
      ) async{
    await Firestore.instance.collection("events").document(eventName.text).updateData({
      username: "invited",
    });
  }

  Widget addingUser(username, eventName) {
    addUser(username, eventName);
    return Text(username + " has been invited.");
  }
}

class DropDown extends StatefulWidget {
  final databaseReference = Firestore.instance;
  final eventName;
  final List<String> listUsers;
  final curIndex;
  final detailsUser;
  final numUsers;

  DropDown(this.eventName, this.listUsers, this.curIndex, this.detailsUser, this.numUsers);
  @override
  MakeBox createState() => MakeBox(eventName, listUsers, curIndex, this.detailsUser, this.numUsers);
}

class MakeBox extends State<DropDown> {
  final detailsUser;
  final numUsers;
  var category;
  var eventName;
  int curIndex;
  List<String> listUsers;
  MakeBox(this.eventName, this.listUsers, this.curIndex, this.detailsUser, this.numUsers);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Who's comin'?"),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text("Here's the list."),
              FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.arrow_drop_down),
                        labelText: 'Color',
                      ),
                      child: new StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) return Text("No Data!");
                            return DropdownButtonFormField<String>(
                              value: category,
                              isDense: true,
                              hint: Text('Who\'s Comin\'?'),
                              onChanged: (newValue) {
                                setState(() {
                                  category = newValue;
                                });
                              },
                              items: snapshot.data != null
                                  ? snapshot.data.documents
                                      .map((DocumentSnapshot document) {
                                      return new DropdownMenuItem<String>(
                                          value: document.data['userName']
                                              .toString(),
                                          child: new Container(
                                            height: 50.0,
                                            //color: primaryColor,
                                            child: new Text(
                                              document.data['userName']
                                                  .toString(),
                                            ),
                                          ));
                                    }).toList()
                                  : new DropdownMenuItem(
                                      value: 'Leave Blank',
                                      child: new Container(
                                        height: 50.0,
                                        child: new Text('Leave Blank'),
                                      ),
                                    ),
                            );
                          }));
                },
              ),
                  FloatingActionButton(
                    onPressed: () {
                      listUsers[curIndex] = category;
                      curIndex += 1;
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                             MainThird(detailsUser: detailsUser, numUsers: numUsers, listUsers: listUsers, curIndex: curIndex)),
                    );
                  },)
            ])));
  }

  Future createUser(eventName, category) async {
    await Firestore.instance.collection("events").document(eventName).setData({
      category: "invited",
    });
  }
}
