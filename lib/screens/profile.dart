import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(ProfileScreen());
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyListView(),
    );
  }
}

class MyListView extends StatelessWidget {
  // const MyApp({super.key});

  Future<String> getUsername(String userId) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check for null before accessing the data
    if (doc.data() == null) {
      return '';
    }

    // Cast the data to a Map<String, dynamic> before usage
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    // Safely access the username field
    return data['username'] ??
        ''; // returns the username if it exists, otherwise an empty string
  }

  final List<Map<String, dynamic>> items = [
    {
      'type': 'text',
      'data': 'Username',
    },
    {
      'type': 'image',
      'data':
          'https://upload.wikimedia.org/wikipedia/commons/4/41/Profile-720.png',
    },
    {
      'type': 'text',
      'data': 'Followers  Following',
    },
    {
      'type': 'picture',
      'data':
          'https://previews.123rf.com/images/happyvector071/happyvector0711904/happyvector071190414500/120957417-creative-illustration-of-default-avatar-profile-placeholder-isolated-on-background-art-design-grey.jpg',
    },
    // Add more items as needed
  ];

  static get images => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item['type'] == 'text') {
            return ListTile(
              title: Center(
                child: Text(
                  item['data'],
                  style: const TextStyle(
                    fontSize: 20.0, // Adjust the font size as needed
                    fontWeight:
                        FontWeight.bold, // Adjust the font weight as needed
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (item['type'] == 'image') {
            return ListTile(
              title: ClipOval(
                child: Container(
                  width: 150.0, // Adjust the size as needed
                  height: 150.0, // Adjust the size as needed
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(item['data']),
                    ),
                  ),
                ),
              ),
            );
          } else if (item['type'] == 'picture') {
            return ListTile(
              title: ClipOval(
                child: Container(
                  width: 50.0, // Adjust the size as needed
                  height: 50.0, // Adjust the size as needed
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(item['data']),
                    ),
                  ),
                ),
              ),
            );
          }

          return SizedBox(); // Return an empty container for unknown types.
        },
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => setState(() => _count++),
        tooltip: 'Increment Counter',
        onPressed: () {},
        child: const Icon(Icons.search),
      ),
    );
    // Horizontal Scroll View
    Container(
      height: 120, // Set the desired height
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          // Add your horizontally scrolling items here
          // For example:
          Container(
            width: 120, // Set the desired width
            color: Colors.blue,
            margin: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Text('Item 1'),
          ),
          Container(
            width: 120, // Set the desired width
            color: Colors.green,
            margin: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Text('Item 2'),
          ),
          // Add more items as needed
        ],
      ),
    );
  }
}
