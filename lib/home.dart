import 'package:ChatNav/chat.dart';
import 'package:ChatNav/navigate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _drawerkey = new GlobalKey();
  int _home = 0;
  var authc = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  // void deactivate() {
  //   super.deactivate();
  // }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Confirm?'),
            content: new Text('Do you want to LogOut?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.popUntil(context, ModalRoute.withName('/login'));
                  Navigator.of(context).pop(true);
                  Navigator.of(context).pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.elliptical(25.0, 15.0),
              ),
            ),
            backgroundColor: Colors.blue.shade800,
            title: Text(
              _home == 0 ? "Chat" : "Navigator",
            )),
        drawer: Drawer(
          key: _drawerkey,
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                curve: Curves.easeOutQuart,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Chat Navigator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1),
                  ),
                  color: Colors.blueAccent,
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.message_outlined),
                  title: Text("Message"),
                  onTap: () {
                    print("navigate to chat");
                    setState(() {
                      _home = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.assistant_navigation),
                  title: Text("Navigator"),
                  onTap: () {
                    print("navigate to maps");
                    setState(() {
                      _home = 1;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.exit_to_app_rounded),
                  title: Text("LogOut"),
                  onTap: () {
                    Fluttertoast.showToast(msg: "Logged Out");
                    authc.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
        body: _home == 0 ? ChatApp() : NavigateApp(),
      ),
    );
  }
}
