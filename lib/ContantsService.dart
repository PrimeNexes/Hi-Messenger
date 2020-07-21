import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';



class DemoApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new MyApp()
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Iterable<Contact> _contacts;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    var contacts = await ContactsService.getContacts();
    setState(() {_contacts = contacts;});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Contacts plugin example')),
      body: new SafeArea(
        child: _contacts != null?
        new ListView.builder(
          itemCount: _contacts?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            Contact c = _contacts?.elementAt(index);
            return new ListTile(
              leading: (c.avatar != null && c.avatar.length > 0) ?
              new CircleAvatar(backgroundImage: new MemoryImage(c.avatar)):
              new CircleAvatar(child:  new Text(c.displayName?.length > 1 ? c.displayName?.substring(0, 2) : "")),
              title: new Text(c.displayName ?? ""),
              subtitle: new Text(c.phones.first.value),
            );
          },
        ):
        new Center(child: new CircularProgressIndicator()),
      ),
    );
  }
}
