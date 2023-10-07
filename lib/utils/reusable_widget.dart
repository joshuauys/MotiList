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
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

class TodoItem extends StatefulWidget {
  final String text;
  final IconData categoryIcon;
  final String description;
  final DateTime date;

  TodoItem({
    required this.text,
    required this.categoryIcon,
    required this.description,
    required this.date,
  });

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool isChecked = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isChecked ? Color.fromARGB(255, 4, 209, 62) : Colors.grey,
      leading: Checkbox(
        value: isChecked,
        activeColor: isChecked ? Colors.amber : Colors.black,
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return isChecked ? Color.fromARGB(255, 189, 9, 239) : Colors.red;
            }
            return Colors
                .grey; // default color when the checkbox is not selected
          },
        ),
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
          });
        },
      ),
      title: Text(widget.text),
      subtitle: isExpanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${widget.description}'),
                Text('Date: ${widget.date.toLocal().toString()}'),
              ],
            )
          : null,
      trailing: Icon(widget.categoryIcon),
      onTap: () {
        setState(() {
          Colors.amber;
          isExpanded = !isExpanded;
        });
      },
    );
  }
}
