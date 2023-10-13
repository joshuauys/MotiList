import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/screens/login_page.dart';

// Import or define the TodoItem widget as well as the WeekCheckbox widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TodoItem> todoItems = [];

  void addTodoItem(TodoItem item) {
    setState(() {
      todoItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Be productive you GOOBER"), centerTitle: true),
      floatingActionButton: FloatingActionButton(onPressed: () {
        _showAddTaskBottomSheet(context, addTodoItem);
      }),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...todoItems,
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

void _showAddTaskBottomSheet(
    BuildContext context, Function(TodoItem) addTodoItem) {
  final TitleController = TextEditingController();
  final DescController = TextEditingController();

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Task', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: TitleController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ensure you have the WeekCheckbox widget defined elsewhere
                WeekCheckbox(char: "M"),
                WeekCheckbox(char: 'T'),
                WeekCheckbox(char: 'W'),
                WeekCheckbox(char: 'TH'),
                WeekCheckbox(char: 'F'),
                WeekCheckbox(char: "SA"),
                WeekCheckbox(char: 'SU'),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: DescController,
              decoration: const InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(55)),
            ),
            const SizedBox(height: 20),
            // Ensure you have the DropdownButtonExample widget defined elsewhere
            const DropdownButtonExample(),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Add Task'),
              onPressed: () {
                final newItem = TodoItem(
                  text: TitleController.text,
                  categoryIcon: Icons.abc,
                  description: DescController.text,
                );
                addTodoItem(newItem);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
