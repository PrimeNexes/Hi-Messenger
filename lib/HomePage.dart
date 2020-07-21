import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:flutter/services.dart';
import 'ChatUser.dart';
import 'package:crypto/crypto.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.googleSignIn, this.analytics, this.auth})
      : super(key: key);

  final String title;
  final googleSignIn;
  final auth;
  final analytics;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();
  static bool _isComposing = false;


  Future<Null> _addFriend({DataSnapshot snapshot}) async {
    DataSnapshot dataSnapshot = await friendRef.child(fireUser.uid + '/' + snapshot.key).once();
    DataSnapshot userTimeSnapshot= await usersRef.child(fireUser.uid).once();
    if (dataSnapshot.value == null) {
      if (snapshot.key.toString() != fireUser.uid.toString()) {
        DatabaseReference _chatId = chatReference.push();
        friendRef.child(fireUser.uid + '/' + snapshot.key).set({
          'displayName': snapshot.value['displayName'],
          'photo': snapshot.value['photo'],
          'time':userTimeSnapshot.value['time'],
          'chatId': _chatId.key
        }).whenComplete(() {
          usersRef.child(fireUser.uid).once().then((fireUserData){
            debugPrint(snapshot.value.toString());
            friendRef.child(snapshot.key + '/' + fireUser.uid).set({
              'displayName':fireUserData.value['displayName'],
              'photo': fireUserData.value['photo'],
              'time':userTimeSnapshot.value['time'],
              'chatId': _chatId.key
            }).whenComplete(() {
              _scaffoldKey.currentState.showSnackBar(
                  new SnackBar(content: new Text("Your new friend is added :D")));
            }).catchError((error) {
              PlatformException e = error;
              _scaffoldKey.currentState
                  .showSnackBar(new SnackBar(content: new Text(e.message)));
            });
          });



        }
        ).catchError((error) {
          PlatformException e = error;
          _scaffoldKey.currentState
              .showSnackBar(new SnackBar(content: new Text(e.message)));
        });
      } else {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text("You can't be your own friend,or can you ?")));
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(dataSnapshot.value['displayName'].toString() +
              " is already your added")));
    }
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    Navigator.pop(context);
    await _searchUsername( phoneNumber: text);
  }

  Future<Null> _searchUsername({String phoneNumber}) async {
    usersRef.orderByChild('username').onChildAdded.listen((Event event) {
      int phoneNumberInt = int.parse("91" + phoneNumber);
      Digest shaPhoneNumber = sha256.convert([phoneNumberInt]);
      event.snapshot.value['phone'] == shaPhoneNumber.toString()
          ? _addFriend(snapshot: event.snapshot)
          : null;
    });
  }

  Future<Null> _onFloatingActionButtonPressed() {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return new SimpleDialog(
              title: new Text('Add a Friend'),
              children: <Widget>[
                new SimpleDialogOption(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          controller: _textController,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          maxLengthEnforced: true,
                          maxLength: 10,
                          onChanged: (String text) {
                            setState(() {
                              _isComposing = text.length >
                                  0; //if(text.length > 0){_isComposing=true;}
                            });
                          },
                          decoration:
                              new InputDecoration.collapsed(hintText: 'Phone'),
                        ),
                      ),
                      new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 4.0),
                        child: new IconTheme(
                          data: new IconThemeData(
                              color: Theme.of(context).accentColor),
                          child: new IconButton(
                              icon: new Icon(Icons.send),
                              onPressed: () => _isComposing
                                  ? _handleSubmitted(_textController.text)
                                  : null),
                        ),
                      )
                    ],
                  ),
                ),
              ]);
        });
  }

  Future<Null> _onClickSignOut(BuildContext context) async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/StartAppPage');
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
            centerTitle: true,
            leading: new IconButton(icon: const Icon(Icons.account_circle), onPressed: (){Navigator.pushNamed(context, '/ProfileSettingPage');}),
            backgroundColor:Theme.of(context).backgroundColor,
            title: new Text(widget.title),
            bottom: new PreferredSize(child: new Container(), preferredSize: Size.fromHeight(8.0)),
            flexibleSpace: new Container(
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: new BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: new BorderRadius.only(bottomLeft: new Radius.circular(16.0),bottomRight: new Radius.circular(16.0)),
                boxShadow: <BoxShadow>[BoxShadow( color: const Color(0xcc000000),
                  blurRadius: 4.0,)],
              ),
            ),
            elevation: 0.0,
            bottomOpacity: 0.0,
            actions: <Widget>[
              new IconButton(
                //icon: new Icon(Icons.account_circle),
                icon: new Icon(Icons.exit_to_app),
                tooltip: 'Sign Out',
                onPressed: () {
                  //setState(() {});
                  _onClickSignOut(context);
                },
              ),
            ]),
        floatingActionButton: new FloatingActionButton(
          onPressed: _onFloatingActionButtonPressed,
          backgroundColor: Theme.of(context).accentColor,
          tooltip: 'Add',
          child: new Icon(Icons.add),
        ),
        body: new Container(
                child: new FirebaseAnimatedList(
                    query: friendRef.child(fireUser.uid),
                    sort: (a, b) => b.key.compareTo(a.key),
                    defaultChild:
                        new Center(child: const CircularProgressIndicator()),
                    padding: new EdgeInsets.all(8.0),
                    reverse: false,
                    itemBuilder: (_, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      return new GestureDetector(
                          child: new ChatUser(
                              snapshot: snapshot, animation: animation));
                    }),
              ));
  }
}
