import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:hi_messenger/ProcessorBlock/ImportInstance.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ProfileSettingPage extends StatefulWidget {
  ProfileSettingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ProfileSettingPageState createState() => _ProfileSettingPageState();
}

class _ProfileSettingPageState extends State<ProfileSettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<DataSnapshot> _getData() async{
    return await usersRef
        .child(fireUser.uid)
        .once();
  }


  Widget _profileSetting() {

    return new FutureBuilder<DataSnapshot>(future: _getData(),builder: (context,snapshot){
      return  snapshot.hasData?new Column(children: <Widget>[
      new GestureDetector(
        onTap: (){
          String displayName=snapshot.data.value['displayName'];
          ImagePicker
            .pickImage(source: ImageSource.gallery)
            .catchError(() => debugPrint("Action Canceled")).then((photoFile){
              if(photoFile!=null){
            StorageReference ref = FirebaseStorage.instance
                    .ref()
                    .child("image_$displayName/IMG_PROFILE_$displayName.jpg");
            ref.putFile(photoFile).future.then((uploadTask){
              usersRef
                  .child(fireUser.uid).update({'photo':uploadTask.downloadUrl.toString()}).then((_){
                    setState(() {
                      _getData();
                    });
              });
            }).catchError((error){
              _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Error "+ error.toString())));
            });}
            else{
                _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Error ",)),);
              }
            });
        },
        child:
          new Container(
              margin: const EdgeInsets.all(16.0),
              child:
              new CircleAvatar(radius: 126.0,backgroundImage:new FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data.value['photo'],
                width: 250.0,

              ).image,)
            ),
      ),

        new Container(
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
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child:new Text(snapshot.data.value['displayName'],style: Theme.of(context).textTheme.display1,),),
                      )),

                ]),
              )
          ),
        ),

//        new Container(
//          margin: const EdgeInsets.all(16.0),
//          child: new RaisedButton(child:new Text("Submit"),
//              onPressed: () async {
//                _isComposing?_createProfile(displayNameController.text,_photoFile,widget.phoneNumber):null;
//              }),)
      ],
      ):const Center(child: CircularProgressIndicator());


    });
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
      body:  new  Center(child:_profileSetting()),
    );
  }
}
