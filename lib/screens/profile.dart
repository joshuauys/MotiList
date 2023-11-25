// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/user.dart';
import 'friend_requests.dart';
//import 'package:MotiList/utils/leaderboard_widgets.dart';
import 'package:MotiList/models/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';

void main() {
  runApp(const ProfileScreen());
}

class CustomSearchDelegate extends SearchDelegate {
  final FirestoreService FS = FirestoreService();
  String selectedResult = "";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    selectedResult = query;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user != null) {
      print(user.username + " sent a request to " + selectedResult);
      FS.sendFriendRequestByUsername(user, selectedResult);
    } else {
      print("No current user found.");
    }

    //final userProvider = Provider.of<UserProvider>(context, listen: false);
    //MyUser? user = userProvider.currentUser;
    //FS.getUidfromUsername(selectedResult);
    //MyUser foundUser = FS.initializeUser(selectedResult);
    //FS.sendFriendRequest(user!, foundUser);

    return Center(
      child: Text(selectedResult),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = [
      // suggestions
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
            print(query);
          },
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyProfileView();
  }
}

class MyProfileView extends StatefulWidget {
  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<String> uploadProfilePhoto(File photoFile, String userId) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      UploadTask uploadTask = storageReference.putFile(photoFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final FirestoreService FS = FirestoreService();
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final user = userProvider.currentUser;

          FS.printFriendRequests(user!);
          showSearch(
            context: context,
            delegate: CustomSearchDelegate(),
          );
        },
        child: const Icon(Icons.search),
      ),
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                setLoginStatus(false);
                setState(() {
                  isLoggedIn = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                print('Error during logout: $e');
                // Handle error if needed
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            alignment: Alignment.bottomCenter,
            tooltip: 'View Friends',
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestsScreen()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Back',
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
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (item['type'] == 'image') {
                  return ListTile(
                    title: ClipOval(
                      child: Container(
                        width: 150.0,
                        height: 150.0,
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
                        width: 50.0,
                        height: 50.0,
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

                return const ListTile();
              },
            ),
          ),
          Container(
            //Landboard background color
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 46, 33, 148)),
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

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  Future<void> setLoginStatus(bool loggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', loggedIn);
  }

  final List<Map<String, dynamic>> items = [
    {'type': 'text', 'data': 'Joshua Uys'},
    {
      'type': 'image',
      'data':
          'https://upload.wikimedia.org/wikipedia/commons/4/41/Profile-720.png',
    },
    {'type': 'text', 'data': 'Followers  Following'},
    {
      'type': 'picture',
      'data':
          'https://previews.123rf.com/images/happyvector071/happyvector0711904/happyvector071190414500/120957417-creative-illustration-of-default-avatar-profile-placeholder-isolated-on-background-art-design-grey.jpg',
    },
  ];
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
