import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';

  final googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAnalytics analytics = new FirebaseAnalytics();
  final DatabaseReference friendRef = FirebaseDatabase.instance.reference()
      .child(
      'friendsList/');
  final DatabaseReference usersRef = FirebaseDatabase.instance.reference()
      .child(
      'users');

  final DatabaseReference chatReference = FirebaseDatabase.instance.reference()
      .child('chats/');
  final DatabaseReference whoIsTypingReference = FirebaseDatabase.instance
      .reference().child('whoIsTyping/');
  FirebaseUser fireUser;

  AppBar hangBar(List<Widget> actions, BuildContext context, Widget title,
      Widget leading) {
    return new AppBar(
        centerTitle: true,
        leading: leading,
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        title: title,
        bottom: new PreferredSize(
            child: new Container(), preferredSize: Size.fromHeight(8.0)),
        flexibleSpace: new Container(
          margin: const EdgeInsets.only(bottom: 6.0),
          decoration: new BoxDecoration(
            color: Theme
                .of(context)
                .accentColor,
            borderRadius: new BorderRadius.only(
                bottomLeft: new Radius.circular(16.0),
                bottomRight: new Radius.circular(16.0)),
            boxShadow: <BoxShadow>[BoxShadow(color: const Color(0xcc000000),
              blurRadius: 4.0,)
            ],
          ),
        ),
        elevation: 0.0,
        bottomOpacity: 0.0,
        actions: actions
    );
  }
