import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/reusable_widget.dart';
import 'package:MotiList/screens/login_page.dart';
import 'package:intl/intl.dart';

// A stateful widget representing the home screen of the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//HomeScreen state, contain all the relevent variables and UI for the home screen
class _HomeScreenState extends State<HomeScreen> {
  final List<TodoItem> todoItems = [];
  var formattedDate = DateFormat('EEEE dd').format(DateTime.now());
  var dayOffset = 0;

  //Returns the formatted week-date for the appbar (e.g. Monday 15)
  set updateFormattedDate(DateTime date) {
    var formatter = DateFormat('EEEE dd');
    setState(() {
      formattedDate = formatter.format(date);
    });
  }

  //Updates build to add new TodoItem to the list
  void addTodoItem(TodoItem item) {
    setState(() {
      todoItems.add(item);
    });
  }

  //Updates build to remove TodoItem from the list
  void removeTodoItem(int index) {
    setState(() {
      todoItems.removeAt(index);
    });
  }

  //Updates build to edit TodoItem in the list
  void editTodoItem(int index, TodoItem newItem) {
    setState(() {
      todoItems[index] = newItem; // Update the item at the given index
    });
  }

  //Updates build to update the date and tasks
  void updateDateAndTasks(int offset) {
    setState(() {
      dayOffset += offset;
      var now = DateTime.now();
      updateFormattedDate = (now.add(Duration(days: dayOffset)));
      // Update the date
      // Update the tasks
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
    // Define a map of category colors
    final Map<String, Color> categoryColors = {
      'Fitness': const Color.fromARGB(255, 155, 11, 226),
      'School': const Color.fromARGB(255, 255, 87, 34),
      'Personal': const Color.fromARGB(255, 76, 175, 80),
      'Work': const Color.fromARGB(255, 33, 150, 243),
    };
    todoItems.forEach((item) {
      categorizedItems[item.category]?.add(item);
    });

    return Scaffold(
      appBar: AppBar(
        //Date is animated to slide in and out when the date changes
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            formattedDate,
            key: ValueKey(formattedDate),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context, addTodoItem);
        },
        child: const Icon(Icons.add),
      ),
      body: GestureDetector(
        //Handles swiping actions
        onHorizontalDragEnd: (details) {
          // The velocity is positive when the swipe direction is right to left.
          if (details.primaryVelocity! < 0) {
            print('Swiped Left to Right');
            updateDateAndTasks(-1);
          } else {
            print('Swiped Right to Left');
            updateDateAndTasks(1);
            // Call the update function when the user swipes right (left to right)
          }
        },

        child: ListView(
          padding: const EdgeInsets.all(8.0),
          //Each category in categorizedItems is mapped to its own container
          children: categorizedItems.entries.map((entry) {
            String category = entry.key;
            List<TodoItem> items = entry.value;
            return Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: categoryColors[
                    category], // Assign a color to the container based on the category
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...items, //Each TodoItem in items is mapped to its own container
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Calling this function adds a widget to create a new TodoItem to the bottom of the screen
void _showAddTaskBottomSheet(
    BuildContext context, void Function(TodoItem) addTodoItem) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String errortext = '';
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
                Text(errortext, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: () {
                    final newItem = TodoItem(
                      text: titleController.text,
                      categoryIcon:
                          Icons.category, // change this icon as needed
                      description: descController.text,
                      category: selectedCategory,
                      onItemUpdated: (newText, newDescription) {},
                    );
                    if (newItem.text.isNotEmpty) {
                      addTodoItem(newItem);
                      Navigator.of(context).pop(); // Close the bottom sheet
                    } else {
                      //Display error messages if no task name is entered
                      setModalState(
                        () {
                          errortext = "Please enter Task Name";
                        },
                      );
                    }
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
