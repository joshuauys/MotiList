// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MotiList/models/task.dart';
import 'package:confetti/confetti.dart';

late ConfettiController _confettiController;

class TodoProvider extends ChangeNotifier {
  List<TodoItem> todoItems = [];

  List<TodoItem> get getTodoItems => todoItems;
  List<TodoItem> get getTodoItemsLength => todoItems;

  void addTodoItem(TodoItem todoItem) {
    todoItems.add(todoItem);
    //print(todoItems.length.toString());
    notifyListeners();
  }

  void deleteTodoItem(TodoItem todoItem) {
    final index =
        todoItems.indexWhere((todoItems) => todoItems.title == todoItem.title);
    todoItems.remove(todoItems[index]);
    notifyListeners();
  }

  void updateTodoItem(TodoItem oldTodoItem, TodoItem newTodoItem) {
    final index = todoItems
        .indexWhere((todoItems) => todoItems.title == oldTodoItem.title);
    todoItems[index] = newTodoItem;
    print(newTodoItem.weekDaysChecked);
    notifyListeners();
  }
}

class TodoItem extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final Map<String, bool> weekDaysChecked;

  const TodoItem({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.weekDaysChecked,

    //required this.onItemUpdated, // Initialize in constructor
  }) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));

    void playConfetti() {
      _confettiController.play();
    }
  }

  void _editCurrentItem() async {
    final oldItem = TodoItem(
        title: widget.title,
        description: widget.description,
        category: widget.category,
        weekDaysChecked: widget.weekDaysChecked);
    // Retrieving current values.
    final currentText = widget.title;
    final currentDescription = widget.description;

    String newSelectedCategory = widget.category;

    // This will hold the new values.
    String newText = '';
    String newDescription = '';

    // Pop up a  to edit the item.
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Task', hintText: 'Enter task name'),
                controller: TextEditingController(text: currentText),
                onChanged: (value) {
                  newText =
                      value; // When the text changes, update the new value.
                },
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Description', hintText: 'Enter description'),
                controller: TextEditingController(text: currentDescription),
                onChanged: (value) {
                  newDescription =
                      value; // Update the new description similarly.
                },
              ),
              DropdownButtonExample(
                onValueChanged: (newValue) {
                  newSelectedCategory = newValue;
                  // Update the state of the modal to reflect the new category
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog when cancel is pressed
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final newItem = TodoItem(
                  title: newText,
                  description: newDescription,
                  category: newSelectedCategory,
                  weekDaysChecked: widget.weekDaysChecked,
                );
                if (newText.isNotEmpty) {
                  // Checking if values are valid
                  Provider.of<TodoProvider>(context, listen: false)
                      .updateTodoItem(oldItem, newItem);
                  Navigator.of(context).pop(); // Dismiss the dialog
                } else {
                  // Something
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Swipe a task in order to delete it
    return Dismissible(
      key: UniqueKey(),
      secondaryBackground: Container(color: Colors.red),
      background: Container(color: Colors.green),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        final oldItem = TodoItem(
            title: widget.title,
            description: widget.description,
            category: widget.category,
            weekDaysChecked: widget.weekDaysChecked);
        Provider.of<TodoProvider>(context, listen: false)
            .deleteTodoItem(oldItem);
        // Call the delete function when the task is dismissed.
      },
      child: GestureDetector(
        onLongPress: () {
          _editCurrentItem(); // Call the edit function on long press.
        },
        child: Stack(
          children: [
            Align(
              widthFactor: 500,
              alignment: Alignment.centerLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,

                shouldLoop: false,
                numberOfParticles: 100,

                colors: const [
                  Colors.orange,
                  Colors.white,
                  Colors.purple
                ], // manually specify the colors to be used
                // createParticlePath: drawStar, // define a custom shape/path.
              ),
            ),
            ListTile(
              tileColor: isChecked
                  ? const Color.fromARGB(255, 4, 209, 62)
                  : Colors.grey,
              leading: Checkbox(
                value: isChecked,
                activeColor: isChecked ? Colors.amber : Colors.black,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return isChecked
                          ? const Color.fromARGB(255, 189, 9, 239)
                          : Colors.red;
                    }
                    return Colors.grey; // Use default color when not selected
                  },
                ),
                onChanged: (bool? value) {
                  if (value == true) {
                    _confettiController = ConfettiController(
                        duration: const Duration(seconds: 1));
                    _confettiController.play();
                  }
                  setState(() {
                    isChecked = value!;

                    TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none);
                  });
                },
              ),
              title: Text(widget.title),
              subtitle: AnimatedSize(
                duration: const Duration(milliseconds: 3300),
                //vsync: this,
                child: isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${widget.description}'),
                          // Uncomment the below line to display the date.
                          //Text('Date: ${widget.date.toLocal().toString()}'),
                        ],
                      )
                    : null,
              ),
              //trailing: Icon(widget.categoryIcon),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> list = <String>[
  'Fitness',
  'School',
  'Hobbies',
  'Work',
  'Finances',
  'Other'
];

class DropdownButtonExample extends StatefulWidget {
  final ValueChanged<String> onValueChanged; // Added a callback
  const DropdownButtonExample({
    Key? key,
    required this.onValueChanged, // Marked as required
  }) : super(key: key);

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        width: 64,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(
          () {
            dropdownValue = newValue!;
          },
        );
        widget.onValueChanged(dropdownValue); // Notify about the change
      },
      items: list.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
    );
  }
}

//Checkbox Class for users to select what days they want to be reminded
class WeekCheckbox extends StatefulWidget {
  String char = "X";
  final Function(bool) onChecked;
  WeekCheckbox({super.key, required this.char, required this.onChecked});

  @override
  _WeekCheckboxState createState() => _WeekCheckboxState(char: char);
}

class _WeekCheckboxState extends State<WeekCheckbox> {
  bool isChecked = false;
  String char = "X";
  _WeekCheckboxState({required this.char});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Checkbox(
          checkColor: Colors.blue,
          value: isChecked,
          onChanged: (bool? value) {
            setState(
              () {
                isChecked = value!;
                widget.onChecked(isChecked);
              },
            );
          },
        ),

        //Prevents the user from clicking on the text thats over the checkbox
        IgnorePointer(
          child: Text(
            char,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber),
          ),
        ),
      ],
    );
  }
}
