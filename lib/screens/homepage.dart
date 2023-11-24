// ignore_for_file: avoid_print

import 'package:MotiList/models/task.dart';
import 'package:flutter/material.dart';
import 'package:MotiList/utils/todo_widgets.dart';
import 'package:intl/intl.dart';
import 'package:MotiList/models/firestore_service.dart';
import 'profile.dart';
import 'package:MotiList/models/task.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

// A stateful widget representing the home screen of the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Application Title',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Feel free to adjust this color
      ),
      home:
          const HomeScreen(), // Setting your HomeScreen as the root of your app.
    );
  }
}

//HomeScreen state, contain all the relevent variables and UI for the home screen
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<TodoItem> todoItems = [];
  var formattedDate = DateFormat('EEEE dd MMM').format(DateTime.now());
  var dayOffset = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  //temp variable for testing, points should eventually be stored in the MyUser class
  int userPoints = 0;

  List<TodoItem> get getTodoItems => todoItems;

  String getCurrentDay() {
    return formattedDate.split(' ')[0];
  }

  //Returns the formatted week-date for the appbar (e.g. Monday 15 July)
  set updateFormattedDate(DateTime date) {
    var formatter = DateFormat('EEEE dd MMM');
    setState(() {
      formattedDate = formatter.format(date);
    });
  }

  //Updates build to add new TodoItem to the list

  //Updates build to update the date and tasks
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);
    // ... other initialization if needed ...
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void updateDateAndTasks(int offset) {
    // Start fade-out
    _fadeController.forward().then((_) {
      dayOffset += offset;
      var now = DateTime.now();
      var newDate =
          DateFormat('EEEE dd').format(now.add(Duration(days: dayOffset)));

      // Update the date and tasks
      setState(() {
        formattedDate = newDate;
      });

      // Start fade-in
      _fadeController.reverse();
    });
  }

  void addPoints(int points) {
    setState(() {
      userPoints += points;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    List<TodoItem> todoList = todoProvider.getTodoItems;
    FirestoreService FS = FirestoreService();

    // Categorizing Todo items
    Map<String, List<TodoItem>> categorizedItems = {
      'Fitness': [],
      'School': [],
      'Hobbies': [],
      'Work': [],
      'Finances': [],
      'Other': [],
    };
    // Define a map of category colors
    final Map<String, Color> categoryColors = {
      'Fitness': const Color.fromARGB(255, 155, 11, 226),
      'School': const Color.fromARGB(255, 255, 87, 34),
      'Hobbies': const Color.fromARGB(255, 76, 175, 80),
      'Work': const Color.fromARGB(255, 33, 150, 243),
      'Finances': const Color.fromARGB(255, 1, 251, 97),
      'Other': const Color.fromARGB(255, 247, 251, 1),
    };
    for (var item in todoList) {
      if (item.weekDaysChecked[getCurrentDay()] ?? false) {
        categorizedItems.putIfAbsent(item.category, () => []).add(item);
      }
    }
    var categoriesToShow = categorizedItems.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 237, 166, 2),
          leading: IconButton(
            icon: const Icon(CupertinoIcons
                .calendar_today), // This button returns user to today's date
            onPressed: () {
              // Handle button press
              print('Button Pressed!');
              updateDateAndTasks(-dayOffset);
            },
          ),
          automaticallyImplyLeading: false,
          //Date is animated to slide in and out when the date changes
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              formattedDate,
              key: ValueKey(formattedDate),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskBottomSheet(context);
            //FS.searchForUserByUsername("Adilling3654");
          },
          child: const Icon(Icons.add),
        ),
        body: GestureDetector(
            //Handles swiping actions
            onHorizontalDragEnd: (details) {
              // The velocity is positive when the swipe direction is right to left.
              if (details.primaryVelocity! < 0) {
                print('Swiped Left to Right');
                updateDateAndTasks(1);
              } else {
                print('Swiped Right to Left');
                updateDateAndTasks(-1);
                // Call the update function when the user swipes right (left to right)
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 86, 9, 194),
                    Color.fromARGB(255, 155, 11, 226),
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: categoriesToShow.length,
                  itemBuilder: (context, index) {
                    String category = categoriesToShow[index].key;

                    // Filter items for the current day.
                    List<TodoItem> itemsForToday =
                        categoriesToShow[index].value;
                    // If there are no items for today, you might want to return an empty container or some placeholder.

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
                          // Use a builder to create a list of items for today
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(), // to nest ListView inside another ListView
                            itemCount: itemsForToday.length,
                            itemBuilder: (context, itemIndex) {
                              TodoItem item = itemsForToday[itemIndex];
                              return TodoItem(
                                key: ValueKey(item),
                                title: item.title,
                                category: item.category,
                                description: item.description,
                                weekDaysChecked: item.weekDaysChecked,
                              );
                            },
                          ),
                          //Text("Points: $userPoints")   this ads the points to the bottom of the category
                        ],
                      ),
                    );
                  },
                ),
              ),
            )));
  }
}

// Calling this function adds a widget to create a new TodoItem to the bottom of the screen
void _showAddTaskBottomSheet(BuildContext context) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  FirestoreService FS = FirestoreService();

  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final user = userProvider.currentUser;

  Map<String, bool> weekDaysChecked = {
    'Sunday': false,
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };
  String errortext = '';
  String selectedCategory = 'Fitness'; // Assume 'Default' is a valid option

  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 10.0, // Adjust the value according to your needs
              left: 10.0, // Adjust the value according to your needs
              right: 10.0, // Adjust the value according to your needs
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WeekCheckbox(
                      char: "M",
                      onChecked: (isChecked) {
                        weekDaysChecked['Monday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "T",
                      onChecked: (isChecked) {
                        weekDaysChecked['Tuesday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "W",
                      onChecked: (isChecked) {
                        weekDaysChecked['Wednesday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "Tu",
                      onChecked: (isChecked) {
                        weekDaysChecked['Thursday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "F",
                      onChecked: (isChecked) {
                        weekDaysChecked['Friday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "Sa",
                      onChecked: (isChecked) {
                        weekDaysChecked['Saturday'] = isChecked;
                      },
                    ),
                    WeekCheckbox(
                      char: "Su",
                      onChecked: (isChecked) {
                        weekDaysChecked['Sunday'] = isChecked;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(errortext, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: () {
                    final newItem = TodoItem(
                        title: titleController.text,
                        description: descController.text,
                        category: selectedCategory,
                        weekDaysChecked: weekDaysChecked

                        //onItemUpdated: (newText, newDescription) {},
                        );
                    if (newItem.title.isNotEmpty) {
                      Provider.of<TodoProvider>(context, listen: false)
                          .addTodoItem(newItem);
                      Task newTask = FS.convertTodoItemToTask(newItem);
                      FS.createTask(user!, newTask);

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
