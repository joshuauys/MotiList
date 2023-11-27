import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reset_password.dart';
import 'package:MotiList/screens/signup_page.dart';
import 'package:MotiList/utils/conv_color.dart';
import 'package:MotiList/utils/register_login_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MotiList/models/firestore_service.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check if the user is logged in from shared preferences
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  Future<void> setLoginStatus(bool loggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', loggedIn);
  }

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final FirestoreService FS = FirestoreService();
  String _errorMessage = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
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
            const Padding(
              padding: EdgeInsets.only(
                  top: 20.0), // Adjust the top padding as needed
              child: Image(
                  image: AssetImage("assets/App Icon.jpg"),
                  height: 101,
                  width: 101),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0), // Adjust the horizontal padding as needed
              child: reusableTextField("Enter Email", Icons.alternate_email,
                  false, _emailTextController),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0), // Adjust the horizontal padding as needed
              child: reusableTextField("Enter Password",
                  CupertinoIcons.lock_fill, true, _passwordTextController),
            ),
            const SizedBox(
              height: 5,
            ),
            //Text("data"),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20.0), // Adjust the right padding as needed
              child: forgetPassword(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: firebaseUIButton(context, "Sign In", () async {
                try {
                  // Step 1: Authenticate the user
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text);

                  // Step 2: Get UID
                  String uid = userCredential.user!.uid;

                  // Step 3: Fetch user's data from Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                  Map<String, dynamic> userData =
                      userDoc.data() as Map<String, dynamic>;

                  // Assuming 'username' is stored in the document
                  String username = userData['username'];

                  // Set user in provider
                  MyUser currentUser = MyUser(uid: uid, username: username);
                  Provider.of<UserProvider>(context, listen: false)
                      .setUser(currentUser);

                  // Proceed further
                  setLoginStatus(true);
                  setState(() {
                    isLoggedIn = true;
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                } on FirebaseAuthException catch (e) {
                  // Handle different authentication errors
                  String errorMessage;
                  switch (e.code) {
                    case "invalid-email":
                      errorMessage =
                          "Your email address is not formatted correctly.";
                      break;
                    case "user-disabled":
                      errorMessage = "Your account has been disabled.";
                      break;
                    case "user-not-found":
                      errorMessage = "User with this email doesn't exist.";
                      break;
                    case "wrong-password":
                      errorMessage = "Invalid password.";
                      break;
                    default:
                      errorMessage = "Error: ${e.message}";
                  }
                  setState(() {
                    _errorMessage = errorMessage;
                  });
                } catch (e) {
                  // Handle other errors
                  print(e);
                  setState(() {
                    _errorMessage = "An error occurred. Please try again.";
                  });
                }
              }),
            ),
            signUpOption(),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    ));
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
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
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
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }
}
