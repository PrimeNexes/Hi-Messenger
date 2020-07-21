import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:hi_messenger/PhoneAuthUI/VerifyPhone.dart';
import 'ProfileSettingPage.dart';


void main() => runApp(new StartApp());
class StartApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      supportedLocales: [
        const Locale('en', 'IN'),
      ],
      title: 'Hi Messenger',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.grey[300],
      ),
      home: new StartAppPage(title: 'Letters'),
      routes: {
        '/StartAppPage': (BuildContext context) =>
        new StartAppPage(title: 'Letters'),
        '/VerifyPhonePage': (BuildContext context) =>
        new VerifyPhonePage(title: 'Letters'),
        '/ProfileSettingPage':(BuildContext context) =>
        new ProfileSettingPage(title: 'Profile'),
        '/HomePage': (BuildContext context) =>
        new HomePage(title: 'Letters')
      },
    );
  }
}

class StartAppPage extends StatefulWidget {
  StartAppPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartAppPageState createState() => new _StartAppPageState();
}

class _StartAppPageState extends State<StartAppPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<Null> _setPersistenceOfFirebase() async {

    await FirebaseDatabase.instance.setPersistenceEnabled(true);
    await FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);
    await friendRef.keepSynced(true);
    await usersRef.keepSynced(true);
    await chatReference.keepSynced(true);
    await whoIsTypingReference.keepSynced(true);
  }

  Future<String> _isUserFunction() async {
    return await auth.currentUser().then((FirebaseUser user) {
      fireUser == null?null: _setPersistenceOfFirebase();
      fireUser == null ? Navigator.of(context).pushReplacementNamed(
          "/VerifyPhonePage") : Navigator.of(context).pushReplacementNamed(
          "/HomePage");
    }).catchError((error){

      PlatformException e = error;
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(e.message)
      ));

    });
  }

  @override
  void initState() {
    super.initState();
    _isUserFunction();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key:_scaffoldKey ,
        appBar: new AppBar(
          backgroundColor:Colors.grey[300],
          bottom: new PreferredSize(child: new Container(), preferredSize: Size.fromHeight(6.0)),
          flexibleSpace: new Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            decoration: new BoxDecoration(
              color: Colors.blue,
              borderRadius: new BorderRadius.only(bottomLeft: new Radius.circular(16.0),bottomRight: new Radius.circular(16.0)),
              boxShadow: <BoxShadow>[BoxShadow( color: const Color(0xcc000000),
                blurRadius: 4.0,)],
            ),
          ),
          elevation: 0.0,
          bottomOpacity: 0.0,
          title: new Text(widget.title),
        ),
        body: new Center(
            child: const CircularProgressIndicator())
    );
  }
}
