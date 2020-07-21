import 'package:flutter/material.dart';
import 'package:hi_messenger/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'ProfilePage.dart';

class SignInWithPhonePage extends StatefulWidget {
  SignInWithPhonePage({Key key, this.title,this.phoneNumber,this.verificationId}) : super(key: key);
  final String title;
  final String phoneNumber;
  final String verificationId;
  @override
  _SignInWithPhoneState createState() => _SignInWithPhoneState();
}


class _SignInWithPhoneState extends State<SignInWithPhonePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController smsCodeController = new TextEditingController();
  bool _isComposing = false;

  void _handleSubmitted(String smsCode){
    _signInWithPhoneNumber(smsCode);
  }


  Future<Null> _signInWithPhoneNumber(String smsCode) async {
    final FirebaseUser user = await auth.signInWithPhoneNumber(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    ).catchError((e){
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content:
          new Text(e.toString()),
          )
      );
    });

    final FirebaseUser currentUser = await auth.currentUser();
    //assert(user.uid == currentUser.uid);
    if(currentUser==null && user==null){
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content:
          new Text( 'Error !! Wrong code maybe ??'),
          )
      );
    }
    else{
        fireUser=currentUser;
        usersRef
            .child(fireUser.uid)
            .once()
            .then((DataSnapshot snapshot) {
                if (snapshot.value.toString() == 'null') {
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                      builder: (BuildContext context) => new ProfilePage(
                        title: "Letters",
                        phoneNumber:widget.phoneNumber,
                      ),
                    ));
                }
                else{
                 Navigator.pushReplacementNamed(context, "/HomePage");

                }
            });
    }
    smsCodeController.text = '';
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _setVerifyPhone(){
    return  new Container(
      margin: const EdgeInsets.only(
          left: 16.0, right: 16.0),
      decoration:
      new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(100.0)),
      child: new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Container(
              child: new Row(children: <Widget>[
                new Container(

                    margin: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new Text("Verification Code",style: TextStyle(color: Theme.of(context).accentColor),)
                ),
                new Flexible(
                    child: new Container(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: new TextField(
                        style: Theme.of(context).textTheme.subhead,
                        textAlign: TextAlign.center,
                        controller: smsCodeController,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        maxLengthEnforced: true,
                        autofocus: true,
                        maxLength: 6,
                        autocorrect: true,
                        onChanged: (String text) {
                          setState(() {
                            _isComposing = text.length >
                                0; //if(text.length > 0){_isComposing=true;}
                          });
                        },
                        onSubmitted: _handleSubmitted,
                        decoration:
                        new InputDecoration.collapsed(
                            hintText:""
                        ),
                      ),
                    )),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.arrow_forward),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(smsCodeController.text)
                        : null,
                  ),
                )
              ]),
            )
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key:_scaffoldKey ,
      backgroundColor: Theme.of(context).backgroundColor,
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
      body:  new  Center(child:_setVerifyPhone()),
    );
  }
}
