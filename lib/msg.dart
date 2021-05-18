import 'package:ChatNav/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  TextEditingController _controller = TextEditingController();
  FocusNode _msgFocusNode = FocusNode();
  // ScrollController _scrollController = ScrollController();
  String _contact;
  String _message;
  FirebaseAuth authc;
  bool isSent;
  FirebaseFirestore fs;

  @override
  void initState() {
    super.initState();
    _contact = contact;
    isSent = true;
    authc = FirebaseAuth.instance;
    fs = FirebaseFirestore.instance;
  }

  updateFirestoreDB(message) async {
    // print(message);
    await fs
        .collection('chats')
        .add({
          'sender': authc.currentUser.email,
          'receiver': _contact,
          'message': message,
          'time': DateTime.now(),
        })
        .then((value) => print(value.toString()))
        .catchError((error) => Fluttertoast.showToast(
              msg: "An Error Occurred",
              backgroundColor: Colors.blue.shade800,
            ));
    setState(() {
      isSent = true;
    });
    _message = null;
    // print('updated');
  }

  deleteFromFireStore(String docId) async {
    // print("Deleting " + docId);
    await fs.collection('chats').doc(docId).delete().then((value) {
      print("deleted");
      Fluttertoast.showToast(
        msg: "Message Deleted",
        backgroundColor: Colors.blue.shade700,
      );
    }).catchError((error) => Fluttertoast.showToast(
          msg: "An Error Occurred",
          backgroundColor: Colors.blue.shade700,
        ));
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, String docId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  size: MediaQuery.of(context).textScaleFactor * 30,
                ),
                Text('Delete Message for All?'),
              ],
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                color: Colors.blue.shade400,
                textColor: Colors.white,
                child: Text('Delete'),
                onPressed: () {
                  deleteFromFireStore(docId);
                  Navigator.pop(context);
                },
              ),
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
  void dispose() {
    _controller.dispose();
    // _scrollController.dispose();
    _msgFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _getChats() {
      return StreamBuilder<QuerySnapshot>(
        stream: fs
            .collection('chats')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'No History to show',
              style: TextStyle(color: Colors.white38),
            ));
          }

          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              if ((snapshot.data.docs[index].data()['receiver'] ==
                          authc.currentUser.email &&
                      snapshot.data.docs[index].data()['sender'] == _contact) ||
                  (snapshot.data.docs[index].data()['sender'] ==
                          authc.currentUser.email &&
                      snapshot.data.docs[index].data()['receiver'] ==
                          _contact)) {
                return GestureDetector(
                  onLongPress: () => _displayTextInputDialog(
                      context, snapshot.data.docs[index].id),
                  child: Bubble(
                    message: snapshot.data.docs[index].data()['message'],
                    isMe: snapshot.data.docs[index].data()['receiver'] ==
                        authc.currentUser.email,
                    delivered:
                        index == snapshot.data.docs.length - 1 ? isSent : true,
                    time: snapshot.data.docs[index].data()['time'].toDate(),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          );
        },
      );
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 500),
      //   curve: Curves.easeOut,
      // );
    }

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.lightGreen,
        elevation: 10.0,
        backgroundColor: Colors.indigo.shade900,
        title: Text(_contact,
            style: TextStyle(
                fontSize: MediaQuery.of(context).textScaleFactor * 18)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded,
              size: MediaQuery.of(context).size.height * 0.05),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
              bottom: MediaQuery.of(context).size.height * 0.09,
            ),
            child: _getChats(),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _msgFocusNode,
                      autocorrect: false,
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).textScaleFactor * 18),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffix: IconButton(
                          iconSize: MediaQuery.of(context).size.width * 0.06,
                          onPressed: () => _controller.clear(),
                          icon: Icon(Icons.clear_rounded),
                        ),
                        hintText: 'Your Message Here',
                      ),
                      onSubmitted: (String x) {
                        _message = x;
                      },
                      onChanged: (String x) {
                        _message = x;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 2.0),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.06,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      tooltip: "Send",
                      onPressed: () {
                        if (_message == null) {
                        } else if (_message.isNotEmpty) {
                          setState(() {
                            isSent = false;
                          });
                          updateFirestoreDB(_message);
                        }
                        _controller.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  Bubble({this.message, this.time, this.delivered, this.isMe});

  final String message;
  final DateTime time;
  final delivered, isMe;

  // String convertTime() {
  //   final DateFormat formatter = DateFormat('jm');
  //   final String formatted = formatter.format(time);
  //   return formatted;
  // }

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.white : Colors.greenAccent.shade100;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe
        ? BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          );
    //final ctime = convertTime();
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
            color: bg,
            borderRadius: radius,
            border: Border.all(width: 0.2),
          ),
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 48.0),
                child: Text(
                  message,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).textScaleFactor * 16),
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      // Text(ctime,
                      //     style: TextStyle(
                      //       color: Colors.black38,
                      //       fontSize: 10.0,
                      //     )),
                      // isMe ? SizedBox() : SizedBox(width: 3.0),
                      !isMe
                          ? Icon(
                              icon,
                              size: 12.0,
                              color: Colors.black38,
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
