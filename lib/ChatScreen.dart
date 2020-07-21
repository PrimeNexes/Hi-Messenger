import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:flutter/services.dart';
import 'ChatMessage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class AnimatedTextComposerBuild extends AnimatedWidget {
  AnimatedTextComposerBuild({Key key, Animation<Color> animation, this.builder})
      : super(key: key, listenable: animation);

  final Widget builder;
  Widget build(BuildContext context) {
    final Animation<Color> animation = listenable;
    return new Container(
      margin:
          const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0, top: 8.0),
      decoration: new BoxDecoration(
          color: animation.value,
          borderRadius: new BorderRadius.circular(100.0)),
      child: builder,
    );
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key, this.title, this.receiverUID, this.photo, this.chatId})
      : super(key: key);

  final String title;
  final String receiverUID;
  final String photo;
  final String chatId;

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _textController = new TextEditingController();

  AnimationController controller;
  Animation<Color> animation;

  bool _isComposing = false;
  bool _otherIsComposing = false;
  TextEditingController _editTextController = new TextEditingController();

  //bool _isComposingEdit = false;

  Future<Null> _setOtherIsComposing(bool setValue) async {
    await whoIsTypingReference
        .child(widget.chatId)
        .child("/isTyping")
        .update({fireUser.uid: setValue});
  }

  Future<Null> _handleOtherIsComposing() async {
    whoIsTypingReference
        .child(widget.chatId)
        .child("/isTyping")
        .child(widget.receiverUID)
        .onValue
        .listen((Event event) {
      setState(() {
        _otherIsComposing = event.snapshot.value == true ? true : false;
      });
      if (event.snapshot.value == true) {
        controller.forward();
      } else {
        controller.reset();
        controller.stop();
      }
    });
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    _setOtherIsComposing(false);
    setState(() {
      _isComposing = false;
    });

    _sendMessage(text: text);
  }

  Future<Null> _handleEditSubmitted(String text, DataSnapshot snapshot) async {
    _editTextController.clear();
    /*setState(() {
      _isComposingEdit = false;
    });*/
    _editMessage(text: text, snapshot: snapshot);
  }

  void _editMessage({String text, String imageUrl, DataSnapshot snapshot}) {
    chatReference.child(widget.chatId).child(snapshot.key).update({
      'text': text,
      'imageUrl': imageUrl,
      'isEdited': true
    }).whenComplete(() => analytics.logEvent(name: 'edited_message'));
    debugPrint("Message Edited");
    Navigator.pop(context);
  }

  Future<Null> _deleteMessage({DataSnapshot snapshot}) async {
    await chatReference
        .child(widget.chatId)
        .child(snapshot.key)
        .remove()
        .whenComplete(() => analytics.logEvent(name: 'delete_message'));
    debugPrint("Message Deleted");
  }

  void _sendMessage({String text, String imageUrl}) {
    DatabaseReference _messageId = chatReference.child(widget.chatId).push();
    _messageId.set({
      'text': text,
      'imageUrl': imageUrl,
      'senderUid': fireUser.uid,
      'receivedUid': widget.receiverUID,
      'time': ServerValue.timestamp,
      'isEdited': false,
      'isReceived': false
    }).whenComplete(() => analytics.logEvent(name: 'send_message'));
    debugPrint("Message Sent");
  }

  Future<Null> _onDoubleTapGesture({DataSnapshot snapshot}) async {
    if (snapshot.value['senderUid'].toString() == fireUser.uid.toString()) {
      return showDialog<Null>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return new AlertDialog(
                content: new Text("Delete message ?",
                    style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Theme.of(context).textTheme.caption.color)),
                actions: <Widget>[
                  new FlatButton(
                      child: const Text('YES'),
                      onPressed: () {
                        _deleteMessage(snapshot: snapshot);
                        Navigator.of(context).pop();
                      } //; }
                      ),
                  new FlatButton(
                      child: const Text('NO'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]);
          });
    }
  }

  Future<Null> _onLongPressGesture({DataSnapshot snapshot}) async {
    if (snapshot.value['imageUrl'] == null &&
        snapshot.value['senderUid'].toString() == fireUser.uid.toString()) {
      _editTextController.text = snapshot.value['text'];
      return showDialog<Null>(
          context: context,
          barrierDismissible: true, // user must tap button!
          builder: (BuildContext context) {
            return new SimpleDialog(
                title: new Text('Edit message'),
                children: <Widget>[
                  new SimpleDialogOption(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Flexible(
                          child: new TextField(
                            textAlign: TextAlign.left,
                            controller: _editTextController,
                            decoration: new InputDecoration.collapsed(
                                hintText: snapshot.value['text']),
                          ),
                        ),
                        new Container(
                          margin: new EdgeInsets.symmetric(horizontal: 4.0),
                          child: new IconTheme(
                            data: new IconThemeData(
                                color: Theme.of(context).accentColor),
                            child: new IconButton(
                                icon: new Icon(Icons.send),
                                onPressed: () => _handleEditSubmitted(
                                    _editTextController.text, snapshot)),
                          ),
                        )
                      ],
                    ),
                  ),
                ]);
          });
    }
  }

  void _animatedInit() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    final Tween colorTween =
        ColorTween(begin: Colors.white, end: Colors.amber[100]);
    animation = colorTween.animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  Widget _buildTextComposer(BuildContext context) {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Container(
              child: new Row(children: <Widget>[
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.photo_camera),
                    onPressed: () async {
                      //await _ensureLoggedIn();
                      File imageFile = await ImagePicker.pickImage(
                              source: ImageSource.gallery)
                          .catchError(() => debugPrint("Action Canceled"));
                      if (imageFile != null) {
                        int random = new Random().nextInt(100000);
                        String user = googleSignIn.currentUser.displayName;
                        StorageReference ref = FirebaseStorage.instance
                            .ref()
                            .child("image_$user/IMG_$random.jpg");
                        StorageUploadTask uploadTask = ref.putFile(imageFile);
                        Uri downloadUrl = (await uploadTask.future).downloadUrl;
                        _sendMessage(imageUrl: downloadUrl.toString());
                      }
                    },
                  ),
                ),
                new Flexible(
                    child: new Container(
                  constraints: new BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.15),
                  child: new TextField(
                    textAlign: TextAlign.left,
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    autocorrect: true,
                    onChanged: (String text) {
                      _handleOtherIsComposing();
                      setState(() {
                        if (text.length == 0) {
                          _setOtherIsComposing(false);
                        } else {
                          _setOtherIsComposing(true);
                        }
                        _isComposing = text.length >
                            0; //if(text.length > 0){_isComposing=true;}
                      });
                    },
                    onSubmitted: _handleSubmitted,
                    decoration: new InputDecoration.collapsed(
                        hintText: _otherIsComposing
                            ? (widget.title + " is typing...")
                            : ("Send a message")),
                  ),
                )),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => _handleSubmitted(_textController.text)
                        : null,
                  ),
                )
              ]),
            )));
  }

  @override
  void initState() {
    super.initState();
    _handleOtherIsComposing();
    _animatedInit();
  }

  @override
  void dispose() {
    controller.dispose();
    _setOtherIsComposing(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[300],
        appBar: new AppBar(
          backgroundColor: Colors.grey[300],
          bottom: new PreferredSize(
              child: new Container(), preferredSize: Size.fromHeight(6.0)),
          flexibleSpace: new Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            decoration: new BoxDecoration(
              color: Colors.blue,
              borderRadius: new BorderRadius.only(
                  bottomLeft: new Radius.circular(16.0),
                  bottomRight: new Radius.circular(16.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xcc000000),
                  blurRadius: 4.0,
                )
              ],
            ),
          ),
          elevation: 0.0,
          bottomOpacity: 0.0,
          centerTitle: true,
          title: new Row(children: <Widget>[
            new Container(
              child: new InkWell(
                child: new CircleAvatar(
                    backgroundImage: new NetworkImage(widget.photo)),
              ),
              padding: const EdgeInsets.only(right: 18.0),
            ),
            new Text(widget.title)
          ]),
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Column(children: <Widget>[
            new Flexible(
              child: new FirebaseAnimatedList(
                query: chatReference.child(widget.chatId),
                sort: (a, b) => b.key.compareTo(a.key),
                defaultChild:
                    new Center(child: const CircularProgressIndicator()),
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  return new GestureDetector(
                      onDoubleTap: () =>
                          _onDoubleTapGesture(snapshot: snapshot),
                      onLongPress: () =>
                          _onLongPressGesture(snapshot: snapshot),
                      child: new ChatMessage(
                        snapshot: snapshot,
                        animation: animation,
                        photo: widget.photo,
                        chatId: widget.chatId,
                        isUser: snapshot.value['senderUid']
                                .toString()
                                .endsWith(fireUser.uid.toString())
                            ? true
                            : false,
                      ));
                },
              ),
            ),
            new AnimatedTextComposerBuild(
                animation: animation, builder: _buildTextComposer(context)),
          ]);
        }));
  }
}
