import 'package:chatty_app_flutter/Screens/WelcomeScreen.dart';
import 'package:chatty_app_flutter/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatty_app_flutter/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebaseFirestore = FirebaseFirestore.instance;
User _user;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AuthClass _authClass = AuthClass();
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        _user = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot
        in _firebaseFirestore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFEEEBE7),
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                //Implement logout functionality
                // messagesStream();
                await _authClass.logout();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => WelcomeScreen()),
                    (route) => false);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessagesStream(),
            Container(
              // decoration: kMessageContainerDecoration,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        onChanged: (value) {
                          //Do something with the user input.
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    CircleAvatar(
                      radius: 22.0,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.send_rounded),
                        color: Color(0xFF2196F3),
                        iconSize: 30.0,
                        onPressed: () {
                          //Implement send functionality.
                          _firebaseFirestore.collection("messages").add({
                            "text": messageController.text,
                            "sender": _user.email,
                            'ts': FieldValue.serverTimestamp(),
                          });
                          messageController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseFirestore.collection("messages").orderBy("ts" ,  descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        }

        final messages = snapshot.data.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message["text"];
          final messageSender = message["sender"];

          final currentUser = _user.email;
          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
          );
          // Text("$messageText from $messageSender");
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: ListView(
              reverse: true,
              children: messageBubbles,
            ),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({Key key, this.sender, this.text, this.isMe, })
      : super(key: key);

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.black54, fontSize: 10.0),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topRight: isMe ? Radius.circular(0.0) : Radius.circular(15.0),
              topLeft: isMe ? Radius.circular(15.0) : Radius.circular(0.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
            elevation: 5.0,
            color: isMe ? Color(0xFFA5D3F6) : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                "$text",
                style: TextStyle(fontSize: 15.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
