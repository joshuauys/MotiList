import 'package:MotiList/screens/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reset_password.dart';
import 'package:MotiList/screens/signup_page.dart';
import 'package:MotiList/utils/conv_color.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/models/user.dart';

import '../models/user.dart';
import '../utils/conv_color.dart';
import '../utils/reset_password.dart';
import '../utils/reusable_widget.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage ({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  hexStringToColor("fffefe"),
                  hexStringToColor("0097fe"),
                  hexStringToColor("0062fe")
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Column(
              children: <Widget>[
              logoWidget("assets/logo.png"),
          const SizedBox(
            height: 30,
          ),
          reusableTextField("Enter Username", Icons.person_outline, false,
              _emailTextController),
          const SizedBox(
            height: 20,
          ),
          reusableTextField("Enter Password", Icons.lock_outline, true,
              _passwordTextController),
          const SizedBox(
            height: 5,
          ),
                forgetPassword(context),
                firebaseUIButton(context, "Sign In", () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text)
                      .then((userCredential) async {
                      final user = userCredential.user;
                      if(user != null) {
                        final uid = user.uid;
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users').doc(uid).get();
                        if (userDoc.exists) {
                          final user = MyUser.fromMap(userDoc.data() as Map<
                              String,
                              dynamic>);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  HomeScreen(user: user)));
                        }
                      }
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                }),
                signUpOption()
              ],
          ),
        ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}