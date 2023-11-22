import 'package:MotiList/utils/todo_widgets.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';
import 'package:provider/provider.dart';
import 'provider.dart'; // Import your provider class
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'MotiList',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false, // Set to true in debug mode
      ),
    );
  }
}
