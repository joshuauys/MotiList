import 'package:MotiList/screens/homepage.dart';
import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container firebaseUIButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}

class TodoItem extends StatefulWidget {
  final String text;
  final IconData categoryIcon;
  final String description;
  final String category;
  final Function(String, String) onItemUpdated; // Added callback

  const TodoItem({
    Key? key,
    required this.text,
    required this.categoryIcon,
    required this.description,
    required this.category,
    required this.onItemUpdated, // Initialize in constructor
  }) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  bool isExpanded = false;

  void _editCurrentItem() async {
    // Retrieving current values.
    final currentText = widget.text;
    final currentDescription = widget.description;

    // This will hold the new values.
    String newText = '';
    String newDescription = '';

    // Here, we pop up a dialog to edit the item.
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
                if (newText.isNotEmpty && newDescription.isNotEmpty) {
                  // Checking if values are valid
                  // We update the task through the callback.
                  widget.onItemUpdated(newText, newDescription);
                  Navigator.of(context).pop(); // Dismiss the dialog
                } else {
                  // You might want to handle the error, or show a warning that fields can't be empty
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
        print("Item dismissed.");
        // Call the delete function when the task is dismissed.
        //widget.onItemDeleted();
      },
      child: GestureDetector(
        onLongPress: () {
          _editCurrentItem(); // Call the edit function on long press.
        },
        child: ListTile(
          tileColor:
              isChecked ? const Color.fromARGB(255, 4, 209, 62) : Colors.grey,
          leading: Checkbox(
            value: isChecked,
            activeColor: isChecked ? Colors.amber : Colors.black,
            fillColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return isChecked
                      ? Color.fromARGB(255, 189, 9, 239)
                      : Colors.red;
                }
                return Colors.grey; // Use default color when not selected
              },
            ),
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
                TextStyle(
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none);
              });
            },
          ),
          title: Text(widget.text),
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
          trailing: Icon(widget.categoryIcon),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
      ),
    );
  }
}

const List<String> list = <String>['Fitness', 'School', 'Personal', 'Work'];

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
  WeekCheckbox({required this.char});

  @override
  _WeekCheckboxState createState() => _WeekCheckboxState(char: this.char);
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

// A single leaderboard item representing each user's data.
class LeaderboardItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int points;

  const LeaderboardItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.points,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          // The circular image.
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 30.0, // You can adjust the size of the avatar as required.
          ),
          const SizedBox(
              width: 15.0), // Some spacing between the picture and the text.
          // User's name and points.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18.0, // Adjust your size as needed.
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$points pts',
                  style: TextStyle(
                    fontSize: 16.0, // Adjust your size as needed.
                    color: Colors.grey[
                        600], // You can choose the appropriate color for your design.
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// The entire leaderboard widget.
class Leaderboard extends StatelessWidget {
  final List<LeaderboardItem> items;

  const Leaderboard({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      ),
    );
  }
}
