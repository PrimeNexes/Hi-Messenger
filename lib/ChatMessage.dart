import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';


class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation, this.photo, this.chatId,this.isUser});

  final DataSnapshot snapshot;
  final Animation animation;
  final String photo;
  final String chatId;
  final bool isUser;


  Future<Null> _isOldMsg() async{
    final DateTime dTime = new DateTime.fromMillisecondsSinceEpoch(snapshot.value['time']+  24 * 60 * 60 * 1000);
    if(DateTime.now().isAfter(dTime)){
      await chatReference
         .child(chatId)
         .child(snapshot.key)
         .remove();
    }
  }

  Color _isReceived() {
    return snapshot.value['isReceived'] == true
        ? Colors.blue[800]
        : Colors.amber[400];
  }

  Future<Null> _setRecevied() async {
      await _isOldMsg();
      if (snapshot.value['receivedUid'].toString().endsWith(fireUser.uid.toString()) && snapshot.value['isReceived']==false) {
        chatReference
            .child(chatId)
            .child(snapshot.key)
            .update({'isReceived': true}).then((_){debugPrint("Written");});
      }
  }

  String _isToday(int time){
    final messageTime = new DateFormat.d().format(new DateTime.fromMillisecondsSinceEpoch(time));
    final String currentTime = new DateFormat.d().format(new DateTime.now());
    String isTodayString;
    if(currentTime==messageTime){
      isTodayString= "Today";

    }
    else{
      isTodayString= "Yesterday";
    }
    return isTodayString;
    }


  String _messageTime(int time){
    final epochTime = new DateTime.fromMillisecondsSinceEpoch(time);
    return _isToday(time)+" , "+new DateFormat.jm().format(epochTime).toString();
  }

  @override
  Widget build(BuildContext context) {
    _setRecevied();
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
          parent: animation,
          curve: Curves.bounceOut,
        ),
        axis: Axis.vertical,
        child: new Column(
          children: <Widget>[
            new Row(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: new Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
//                          new Container(
//                              margin: const EdgeInsets.only(right: 8.0),
//                              child: isUser
//                                  ? null
//                                  : new CircleAvatar(
//                                  backgroundImage:
//                                  new NetworkImage(photo))),
                          new Container(
                            padding:
                            const EdgeInsets.only(right: 12.0, left: 12.0),
                            decoration: new BoxDecoration(
                              color: isUser ? _isReceived() : Colors.white70,
                              /*isUser?Colors.blue[800]:Colors.white70,*/
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            constraints: new BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.6),
                            child: new Container(
                              margin: const EdgeInsets.only(
                                  top: 10.0, bottom: 10.0),
                              child: snapshot.value['imageUrl'] != null
                                  ? new FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: snapshot.value['imageUrl'],
                                width: 250.0,
                              )
                                  : new Text(
                                snapshot.value['text'],
                                style: isUser
                                    ? Theme
                                    .of(context)
                                    .accentTextTheme
                                    .subhead
                                    : DefaultTextStyle.of(context).style,
                              ),
                            ),
                          ),
                        ],
                      ),
                      new Container(
                        margin: const EdgeInsets.only(
                            right: 8.0, top: 2.0, left: 8.0),
                        child: new Text(
                          _messageTime(snapshot.value['time']),
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}