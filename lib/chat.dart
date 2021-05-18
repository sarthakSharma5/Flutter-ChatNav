import 'package:ChatNav/msg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

String contact;

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with TickerProviderStateMixin {
  FirebaseAuth authc;
  FirebaseFirestore fs;
  Set<String> contacts;
  TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    authc = FirebaseAuth.instance;
    _textFieldController = TextEditingController();
    fs = FirebaseFirestore.instance;
    contacts = {};
    contact = null;
  }

  @override
  void dispose() {
    contact = null;
    contacts.clear();
    _textFieldController.dispose();
    super.dispose();
  }

  Route _changeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Message(),
      transitionDuration: Duration(milliseconds: 800),
      barrierColor: Colors.white38,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.linearToEaseOut));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add New Contact'),
            content: TextField(
              onChanged: (value) {
                contact = value;
              },
              controller: _textFieldController,
              decoration: InputDecoration(
                hintText: "User Email",
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Colors.blue.shade400,
                textColor: Colors.white,
                child: Text('Add'),
                onPressed: () {
                  if (contact == null) {
                  } else if (!contact.contains("@")) {
                    Fluttertoast.showToast(
                        msg: "Specify email", timeInSecForIosWeb: 1);
                  } else if (contact == authc.currentUser.email) {
                    Fluttertoast.showToast(
                        msg: "email of Receiver", timeInSecForIosWeb: 1);
                  } else if (contact.isNotEmpty) {
                    setState(() {
                      contacts.clear();
                    });
                    //Navigator.pop(context);
                    //Navigator.pushNamed(context, '/msg');
                    Navigator.of(context).push(_changeRoute());
                  }
                },
              ),
              // ignore: deprecated_member_use
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Colors.blue.shade400,
                elevation: 4,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  contact = null;
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _mychats() {
      return StreamBuilder(
        stream: fs
            .collection('chats')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'Start Chatting',
              style: TextStyle(color: Colors.white38),
            ));
          }
          contacts.clear();
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.data.docs[index].data()['sender'] !=
                  authc.currentUser.email) {
                if (snapshot.data.docs[index].data()['receiver'] !=
                    authc.currentUser.email) {
                  return SizedBox();
                }
              }

              if (contacts.contains(authc.currentUser.email ==
                      snapshot.data.docs[index].data()['sender']
                  ? snapshot.data.docs[index].data()['receiver']
                  : snapshot.data.docs[index].data()['sender'])) {
                return SizedBox();
              }

              authc.currentUser.email ==
                      snapshot.data.docs[index].data()['sender']
                  ? contacts.add(snapshot.data.docs[index].data()['receiver'])
                  : contacts.add(snapshot.data.docs[index].data()['sender']);

              return Container(
                margin: EdgeInsets.fromLTRB(0, 3, 3, 3),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.6, color: Colors.black38),
                  borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(5),
                    topRight: Radius.circular(20),
                    //bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    contact = authc.currentUser.email ==
                            snapshot.data.docs[index].data()['sender']
                        ? snapshot.data.docs[index].data()['receiver']
                        : snapshot.data.docs[index].data()['sender'];
                    setState(() {
                      contacts.clear();
                    });
                    //Navigator.pop(context);
                    //Navigator.pushNamed(context, "/msg");
                    Navigator.of(context).push(_changeRoute());
                  },
                  onLongPress: () {},
                  title: Text(
                    authc.currentUser.email ==
                            snapshot.data.docs[index].data()['sender']
                        ? snapshot.data.docs[index]
                            .data()['receiver']
                            .toString()
                        : snapshot.data.docs[index]
                            .data()['sender']
                            .toString()
                            .replaceAll("@gmail.com", ""),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade600,
                    child: Tooltip(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      message: "Last Message",
                      showDuration: Duration(seconds: 1),
                      child: GestureDetector(
                        onTap: () => Fluttertoast.showToast(
                            msg: snapshot.data.docs[index].data()['message'],
                            timeInSecForIosWeb: 1),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Stack(
      children: [
        _mychats(),
        Container(
          margin: EdgeInsets.all(25),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              child: Icon(Icons.messenger_outline_rounded),
              tooltip: "add contact",
              onPressed: () => _displayTextInputDialog(context),
            ),
          ),
        ),
      ],
    );
  }
}
