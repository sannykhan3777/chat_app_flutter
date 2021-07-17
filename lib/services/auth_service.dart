import 'package:chatty_app_flutter/Screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass {
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
  //   "email",
  //   "https://www.googleapis.com/auth/contacts.writeonly",
  // ]);
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();

  Future<void> googleSignin(BuildContext context) async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        try {
          UserCredential userCredential =
              await _auth.signInWithCredential(authCredential);
          storeTokenAndData(userCredential);
          // print(userCredential.credential.token);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => ChatScreen()),
              (route) => false);
        } catch (e) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(content: Text("Not Able to Sign In"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
        key: "token", value: userCredential.credential.token.toString());
    await storage.write(key: "token", value: userCredential.toString());
  }

  Future<String> getToken() async {
    return await storage.read(key: "token");
  }

  Future<void> logout() async {
    try {
     await _googleSignIn.signOut();
     await _auth.signOut();
     await storage.delete(key: "token");
    }
    catch (e) {
      
    }
  }
}
