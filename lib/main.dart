import 'package:chatty_app_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chatty_app_flutter/Screens/WelcomeScreen.dart';
import 'package:chatty_app_flutter/Screens/chat_screen.dart';
import 'package:chatty_app_flutter/Screens/login_screen.dart';
import 'package:chatty_app_flutter/Screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChattyApp());
}

class ChattyApp extends StatefulWidget {
  const ChattyApp({Key key}) : super(key: key);

  @override
  _ChattyAppState createState() => _ChattyAppState();
}

class _ChattyAppState extends State<ChattyApp> {

  Widget currentPage = WelcomeScreen();
  AuthClass _authClass = AuthClass();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    String tokenn = await _authClass.getToken();
    if(tokenn!=null) {
      setState(() {
        currentPage = ChatScreen();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: currentPage,
      // initialRoute: "/currentpage",
      routes: {
        // "/currentpage" : (context) => currentPage,
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
