import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/screens/login_page.dart';

// A stateful widget representing the home screen of the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//HomeScreen state, contain all the relevent variables and UI for the home screen
class _HomeScreenState extends State<HomeScreen> {
  final List<TodoItem> todoItems = [];

  //Updates build to add new TodoItem to the list
  void addTodoItem(TodoItem item) {
    setState(() {
      todoItems.add(item);
    });
  }

  void editTodoItem(int index, TodoItem newItem) {
    setState(() {
      todoItems[index] = newItem; // Update the item at the given index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Categorizing Todo items
    Map<String, List<TodoItem>> categorizedItems = {
      'Fitness': [],
      'School': [],
      'Personal': [],
      'Work': []
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
              color: Color.fromARGB(255, 155, 11, 226),
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
    BuildContext context, void Function(TodoItem) addTodoItem) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String selectedCategory = 'Fitness'; // Assume 'Default' is a valid option

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add New Task', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonExample(
                  onValueChanged: (newValue) {
                    selectedCategory = newValue;
                    // Update the state of the modal to reflect the new category
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WeekCheckbox(char: "S"),
                    WeekCheckbox(char: "M"),
                    WeekCheckbox(char: "T"),
                    WeekCheckbox(char: "W"),
                    WeekCheckbox(char: "T"),
                    WeekCheckbox(char: "F"),
                    WeekCheckbox(char: "S"),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newItem = TodoItem(
                      text: titleController.text,
                      categoryIcon:
                          Icons.category, // change this icon as needed
                      description: descController.text,
                      category: selectedCategory,
                      onItemUpdated: (newText, newDescription) {
                        // You will need to implement the logic to handle the updating of the item in your list of tasks
                      },
                    );

                    // Assuming you have a method in your _HomeScreenState to add a TodoItem
                    addTodoItem(
                        newItem); // Make sure to define/implement this method

                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: const Text('Add Task'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
