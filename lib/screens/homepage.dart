import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/screens/login_page.dart';

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
    // Categorizing Todo items
    Map<String, List<TodoItem>> categorizedItems = {
      'Fitness': [],
      'School': [],
      'Personal': [],
      'Frog-Related Hobbies': []
    };

    todoItems.forEach((item) {
      categorizedItems[item.category]?.add(item);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Be productive you GOOBER"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        _showAddTaskBottomSheet(context, addTodoItem);
      }),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: categorizedItems.entries.map((entry) {
          String category = entry.key;
          List<TodoItem> items = entry.value;

          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...items,
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

void _showAddTaskBottomSheet(
    BuildContext context, Function(TodoItem) addTodoItem) {
  final TitleController = TextEditingController();
  final DescController = TextEditingController();
  String selectedCategory = list.first;

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
            //return value from DropdownButtonExample()

            const SizedBox(height: 20),
            DropdownButtonExample(
              onValueChanged: (newValue) {
                selectedCategory = newValue;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Add Task'),
              onPressed: () {
                //return category based on DropdownButtomExample value

                final newItem = TodoItem(
                  text: TitleController.text,
                  categoryIcon: Icons.abc,
                  description: DescController.text,
                  category: selectedCategory,
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
