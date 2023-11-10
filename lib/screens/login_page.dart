import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reset_password.dart';
import 'package:MotiList/screens/signup_page.dart';
import 'package:MotiList/utils/conv_color.dart';
import 'package:MotiList/utils/reusable_widget.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  String _errorMessage = "";
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
            //Add image from "assets/Dog.jpg"
            const SizedBox(
              height: 30,
            ),
            const Image(
                image: AssetImage("assets/App Icon.jpg"),
                height: 101,
                width: 101),
            const SizedBox(
              height: 30,
            ),
            reusableTextField("Enter Email", Icons.person_outline, false,
                _emailTextController),
            const SizedBox(
              height: 10,
            ),
            reusableTextField("Enter Password", Icons.lock_outline, true,
                _passwordTextController),
            const SizedBox(
              height: 5,
            ),
            //Text("data"),
            forgetPassword(context),
            firebaseUIButton(context, "Sign In", () {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text)
                  .then((value) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }).catchError((error) {
                switch (error.code) {
                  case "invalid-email":
                    setState(() {
                      _errorMessage =
                          "Your email address is not formated correctly.";
                    });
                    break;
                  case "user-disabled":
                    setState(() {
                      _errorMessage = "Your account has been disabled.";
                    });
                    break;
                  case "user-not-found":
                    setState(() {
                      _errorMessage = "User with this email doesn't exist.";
                    });
                    break;
                  case "wrong-password":
                    setState(() {
                      _errorMessage = "Invalid password.";
                    });
                    break;
                  default:
                    setState(() {
                      _errorMessage = "Error ${error.toString()}";
                    });
                }
              });
            }),
            signUpOption(),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            )
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
