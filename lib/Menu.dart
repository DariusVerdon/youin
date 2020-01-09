import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'ProfileScreen.dart';

class FirstRoute extends StatelessWidget {
  final UserDetails detailsUser;
  final int numUsers;

  FirstRoute({Key key, @required this.detailsUser, @required this.numUsers}) : super(key: key);

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
                          builder: (context) => ThirdRoute(detailsUser, numUsers)),
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

class ThirdRoute extends StatelessWidget {
  final eventName = TextEditingController();
  final location = TextEditingController();
  final time = TextEditingController();

  final databaseReference = Firestore.instance;
  final UserDetails detailsUser;

  final int numUsers;

  ThirdRoute(this.detailsUser, this.numUsers);

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
                for (var i = 0; i < numUsers -1; i++) DropDown(),
            FloatingActionButton(onPressed: () {
              createRecord(
                  databaseReference, detailsUser, eventName, location, time);
              print("the record has been created");
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

  Widget createUsers(eventName, chosen) {
    for (var i in chosen)
    Firestore.instance
        .collection("events")
        .document(eventName)
        .setData({
        i: true,
    });
    return Text("User Added");
  }
}

class DropDown extends StatefulWidget {
  const DropDown({ Key key }) : super(key: key);

  @override
  MakeBox createState() => MakeBox();
}

class MakeBox extends State<DropDown> {
  var category;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Text("No Data!");
          return DropdownButton<String>(
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
                  value: document.data['userName'].toString(),
                  child: new Container(
                    height: 50.0,
                    //color: primaryColor,
                    child: new Text(
                      document.data['userName'].toString(),
                    ),
                  ));
            }).toList()
                : DropdownMenuItem(
              value: 'Leave Blank',
              child: new Container(
                height: 50.0,
                child: new Text('Leave Blankyo'),
              ),
            ),
          );
        });
  }

}
