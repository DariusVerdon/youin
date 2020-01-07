import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'You In? Sign in.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff9C58D2),
      ),
      home: GoogleSignApp(),
    );
  }
}

class GoogleSignApp extends StatefulWidget {
  @override
  _GoogleSignAppState createState() => _GoogleSignAppState();
}

class _GoogleSignAppState extends State<GoogleSignApp> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();

  final db = Firestore.instance;

  Future<FirebaseUser> _signIn(BuildContext context) async {

    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Sign in'),
    ));

    final GoogleSignInAccount googleUser = await _googlSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
    );



    var name = db.collection("users").toString();



    final AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser userDetails = authResult.user;

    ProviderDetails providerInfo = new ProviderDetails(userDetails.providerId);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    UserDetails details = new UserDetails(
      userDetails.providerId,
      userDetails.displayName,
      userDetails.photoUrl,
      userDetails.email,
      providerData,
    );

    createUser(db, details);
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => FirstRoute(detailsUser: details),//new ProfileScreen(detailsUser: details),
      ),
    );
    return userDetails;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.height,
              child: Image.network(
                  'https://cdn.clipart.email/040c32754ef22cf9829b20e6bc3ed0a0_anime-wallpaper-phone-32-images-on-genchiinfo_1080-1920.jpeg'
                  ,fit: BoxFit.fill,
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  colorBlendMode: BlendMode.modulate
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height:10.0),
                Container(
                    width: 250.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xffffffff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.google,color: Color(0xffCE107C),),
                            SizedBox(width:10.0),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(color: Colors.black,fontSize: 18.0),
                            ),
                          ],),
                        onPressed: () => _signIn(context)
                            .then((FirebaseUser user) => print(user))
                            .catchError((e) => print(e)),
                      ),
                    )
                ),

                              ],
            ),
          ],
        ),),
    );
  }
}



class UserDetails {
  final String providerDetails;
  final String userName;
  final String photoUrl;
  final String userEmail;
  final List<ProviderDetails> providerData;

  UserDetails(this.providerDetails,this.userName, this.photoUrl,this.userEmail, this.providerData);
}


class ProviderDetails {
  ProviderDetails(this.providerDetails);
  final String providerDetails;
}

Future createUser(databaseReference, detailsUser) async {
  await databaseReference
      .collection("users")
      .document(detailsUser.userName)
      .setData({
    'userName': detailsUser.userName,
    'userEmail': detailsUser.userEmail,
    'photo': detailsUser.photoUrl,
    'loginTime': DateTime.now(),

  });

}

