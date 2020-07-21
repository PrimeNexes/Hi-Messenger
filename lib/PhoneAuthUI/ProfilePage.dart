import 'package:flutter/material.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title,this.phoneNumber}) : super(key: key);
  final String title;
  final String phoneNumber;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = new TextEditingController();
  bool _isComposing = false;
  File _photoFile;



  Future<Null> _createProfile(String displayName,File photoFile,String phoneNumber) async {
    int phoneNumberInt = int.parse("91" + phoneNumber);
    Digest shaPhoneNumber = sha256.convert([phoneNumberInt]);
    String photoUrl;
    if (photoFile != null) {
      StorageReference ref = FirebaseStorage.instance
          .ref()
          .child("image_$displayName/IMG_PROFILE_$displayName.jpg");
      StorageUploadTask uploadTask = ref.putFile(photoFile);
      photoUrl = (await uploadTask.future).downloadUrl.toString();
    }
    else{
      photoUrl ="https://firebasestorage.googleapis.com/v0/b/learned-stone-193416.appspot.com/o/icon-user-default.png?alt=media&token=e24c9a43-13eb-42d5-b019-25e4ec837a65";
    }
    print("Adding");
    await usersRef.child(fireUser.uid).set({
      'phone': shaPhoneNumber.toString(),
      'photo': photoUrl,
      'displayName': displayName,
      'time': ServerValue.timestamp
    }).whenComplete((){Navigator.pushReplacementNamed(context, "/HomePage");});

  }



  Widget _setVerifyPhone(){
    return  new Column(children: <Widget>[
      new Container(
        margin: const EdgeInsets.all(16.0),
        child: new RaisedButton(child:new Text("Upload Profile Image"),onPressed: ()async{
        _photoFile=await ImagePicker
            .pickImage(source: ImageSource.gallery)
            .catchError(() => debugPrint("Action Canceled"));
      }),)

      ,new Container(
      margin: const EdgeInsets.only(
          left: 16.0, right: 16.0),
      decoration:
      new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular(100.0)),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Container(
            child: new Row(children: <Widget>[
              new Container(),
              new Flexible(
                  child: new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new TextField(
                      style: Theme.of(context).textTheme.subhead,
                      textAlign: TextAlign.left,
                      controller: displayNameController,
                      maxLines: 1,
                      autofocus: true,
                      autocorrect: false,
                      onChanged: (String text) {
                        setState(() {
                          _isComposing = text.length >
                              0; //if(text.length > 0){_isComposing=true;}
                        });
                      },
                      decoration:
                      new InputDecoration.collapsed(
                          hintText:"Display Name"
                      ),
                    ),
                  )),

            ]),
          )
      ),
    ),
    new Container(
      margin: const EdgeInsets.all(16.0),
      child: new RaisedButton(child:new Text("Submit"),
          onPressed: () async {
            _isComposing?_createProfile(displayNameController.text,_photoFile,widget.phoneNumber):null;
          }),)
    ],
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
      body:  _setVerifyPhone(),
    );
  }
}
