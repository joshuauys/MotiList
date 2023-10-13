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

void _showAddTaskBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures only necessary space is taken
          children: [
            const Text('Add New Task', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              WeekCheckbox(char: "M"),
              WeekCheckbox(char: 'T'),
              WeekCheckbox(char: 'W'),
              WeekCheckbox(char: 'TH'),
              WeekCheckbox(char: 'F'),
              WeekCheckbox(char: "SA"),
              WeekCheckbox(char: 'SU'),
            ]),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(55)),
            ),
            const SizedBox(height: 20),
            const DropdownButtonExample(),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Add Task'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

//This logout button should be moved to the profile page or settings
class _HomeScreenState extends State<HomeScreen> {
  List<String> todoItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Be productive you GOOBER"), centerTitle: true),
      floatingActionButton: FloatingActionButton(onPressed: () {
        todoItems.add('New Todo ${todoItems.length + 1}');
        _showAddTaskBottomSheet(context);
        print(todoItems);
      }),
      body: Container(
        //alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TodoItem(
              text: 'Learn Flutter',
              categoryIcon: Icons.school,
              description: 'Complete the Flutter course on XYZ platform.',
              date: DateTime.now().add(const Duration(days: 2)),
            ),
            TodoItem(
              text: 'Kill a group member',
              categoryIcon: Icons.school,
              description: 'They will never know',
              date: DateTime.now().add(const Duration(days: 2)),
            ),
            TodoItem(
              text: 'Eat',
              categoryIcon: Icons.school,
              description: 'Complete the Flutter course on XYZ platform.',
              date: DateTime.now().add(const Duration(days: 2)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                child: const Text("Logout"),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then(
                    (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
