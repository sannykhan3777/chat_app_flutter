import 'package:chatty_app_flutter/Screens/chat_screen.dart';
import 'package:chatty_app_flutter/components/rounded_button.dart';
import 'package:chatty_app_flutter/constants.dart';
import 'package:chatty_app_flutter/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool circular = false;
  AuthClass _authClass = AuthClass();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Color(0xFF2196F3),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B9C11)),
        ),
        inAsyncCall: circular,
        opacity: 0.3,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Hero(
                      tag: "logo",
                      child: Container(
                        height: height * 0.24,
                        child: Image.asset('assets/logo1.png'),
                      ),
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: "Enter Your Email"),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                        controller: passController,
                        obscureText: true,
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: "Enter Your Password")),
                    SizedBox(
                      height: 24.0,
                    ),
                    RoundedButton(
                      height: height,
                      title: "Log In",
                      colour: Color(0xFF2196F3),
                      onPressed: () async {
                        setState(() {
                          circular = true;
                        });
                        try {
                          UserCredential userCredential =
                              await _auth.signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passController.text.trim());
                          print(userCredential.user.email);
                          setState(() {
                            circular = false;
                          });
                          // Navigator.pushNamed(context, RegistrationScreen.id);
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder) => ChatScreen()), (route) => false);

                        } catch (e) {
                          final snackBar = SnackBar(content: Text(e.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            circular = false;
                          });
                        }
                        // Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "OR",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RoundedButtonGoogle(
                      height: height,
                      title: "Sign In with Google",
                      colour: Color(0xFF1B9C11),
                      onPressed: () async {
                        setState(() {
                          circular = true;
                        });
                        try {
                          await _authClass.googleSignin(context);

                          setState(() {
                            circular = false;
                          });
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder) => ChatScreen()), (route) => false);
                        }
                        catch (e) {
                          final snackBar = SnackBar(content: Text(e.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            circular = false;
                          });
                        }


                        // Navigator.pushNamed(context, RegistrationScreen.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
