import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ChatScreen.dart';

class ChatUser extends StatelessWidget {
  ChatUser({this.snapshot, this.animation});

  final DataSnapshot snapshot;
  final Animation animation;


  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
          parent: animation,
          curve: Curves.bounceOut,
        ),
        axis: Axis.vertical,
        child: new Container(
            decoration: new BoxDecoration(
                color: Colors.white70,
                borderRadius: new BorderRadius.circular(12.0)),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: new ListTile(
              leading: new CircleAvatar(
                  backgroundImage: new NetworkImage(snapshot.value['photo'])),
              title: new Text(snapshot.value['displayName']),
              onTap: () async {
                snapshot.value['chatId'] == null
                    ? Navigator.push(context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new ChatScreen(
                          title: snapshot.value['displayName'],
                          receiverUID: snapshot.key,
                          photo: snapshot.value['photo'],
                          chatId: null,

                      ),
                    ))
                    : Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new ChatScreen(
                          title: snapshot.value['displayName'],
                          receiverUID: snapshot.key,
                          photo: snapshot.value['photo'],
                          chatId: snapshot.value['chatId'].toString(),

                          ),
                    ));
              },
            )
        )
    );
  }
}