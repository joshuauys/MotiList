import 'package:MotiList/utils/todo_widgets.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_options.dart';
import 'package:provider/provider.dart';
import 'provider.dart'; // Import your provider class
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quick_actions/quick_actions.dart';

import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    initializeQuickActions();
    super.initState();
  }

  initializeQuickActions() {
    quickActions.initialize((String shortcutType) {
      switch (shortcutType) {
        case 'First Page Screen':
          _navigate('/firstpage');
          return;
        case 'Second Page Screen':
          _navigate('/secondpage');
          return;
        default:
          _navigate('/firstpage');
          return;
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'First Page Screen',
        localizedTitle: 'First Page',
        icon: 'image1', // Replace with the actual name of your image asset
      ),
      const ShortcutItem(
        type: 'Second Page Screen',
        localizedTitle: 'Second Page',
        icon: 'image1', // Replace with the actual name of your image asset
      ),
    ]);
  }

  _navigate(String screen) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    Navigator.pushNamed(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
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
