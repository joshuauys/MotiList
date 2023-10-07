import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/screens/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class CheckboxExampleApp extends StatelessWidget {
  const CheckboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Checkbox Sample')),
        body: const Center(
          child: CheckboxExample(),
        ),
      ),
    );
  }
}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}

//This logout button should be moved to the profile page or settings
class _HomeScreenState extends State<HomeScreen> {
  List<String> todoItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        todoItems.add('New Todo ${todoItems.length + 1}');
        print(todoItems);
      }),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TodoItem(
            text: 'Learn Flutter',
            categoryIcon: Icons.school,
            description: 'Complete the Flutter course on XYZ platform.',
            date: DateTime.now().add(Duration(days: 2)),
          ),
          TodoItem(
            text: 'Kill a group member',
            categoryIcon: Icons.school,
            description: 'They will never know',
            date: DateTime.now().add(Duration(days: 2)),
          ),
          TodoItem(
            text: 'Eat',
            categoryIcon: Icons.school,
            description: 'Complete the Flutter course on XYZ platform.',
            date: DateTime.now().add(Duration(days: 2)),
          ), // This includes the CheckboxExample's build output
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              child: Text("Logout"),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
