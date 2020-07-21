import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hi_messenger/PhoneAuthUI/SignInWithPhonePage.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:hi_messenger/HomePage.dart';

class VerifyPhonePage extends StatefulWidget {
  VerifyPhonePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _VerifyPhonePageState createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController phoneNumberController = new TextEditingController();
  bool _isComposing = false;
  String verificationId;

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      fireUser=user;
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content:
          new Text( 'Verification successful !'),
          )
      );
      debugPrint(fireUser.toString());
      Navigator.pushReplacementNamed(context, '/HomePage');
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content:
          new Text( 'Phone numbber verification failed. Code: ${authException.code}. Message: ${authException.message}'),
          )
      );
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      Navigator.pushReplacement(context,
          new MaterialPageRoute(
            builder: (BuildContext context) => new SignInWithPhonePage(
              title: "Letters",
              phoneNumber:phoneNumber,
              verificationId: this.verificationId,
            ),
          )
      );
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content:
          new Text( 'Time Out'),
          )
      );
    };
    await auth.verifyPhoneNumber(
        phoneNumber: "+91"+phoneNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

  }


  void _handleSubmitted(String phoneNumber){
    _verifyPhoneNumber(phoneNumber);

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
                  child: new Text("+91",style: TextStyle(color: Theme.of(context).accentColor),)
              ),
              new Flexible(
                  child: new Container(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: new TextField(
                      textAlign: TextAlign.left,
                      controller: phoneNumberController,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      maxLengthEnforced: true,
                      maxLength: 10,
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
                          hintText:"Phone Number"
                      ),
                    ),
                  )),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.arrow_forward),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(phoneNumberController.text)
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
