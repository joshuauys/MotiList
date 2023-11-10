import 'package:flutter/material.dart';
//import 'package:MotiList/utils/reusable_widget.dart';

void main() {
  runApp(const ProfileScreen());
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyProfileView();
  }
}

class MyProfileView extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'type': 'text',
      'data': 'Joshua Uys',
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

  MyProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                          fontWeight: FontWeight
                              .bold, // Adjust the font weight as needed
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

                return const ListTile(
                    // Depending on your item type, return appropriate widgets
                    );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LeaderboardItem(
                  imageUrl: 'assets/Thumbs2.jpg',
                  name: 'TaskLover25',
                  points: 100,
                ),
                LeaderboardItem(
                  imageUrl: 'assets/Thumbs.jpg',
                  name: 'DopamineDad',
                  points: 200,
                ),
                LeaderboardItem(
                  imageUrl: 'assets/Dog3.jpg',
                  name: 'LoveMeSomeTasks',
                  points: 150,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$points points',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
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
