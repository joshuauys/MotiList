// ignore_for_file: avoid_print

import 'package:MotiList/models/leaderboard_entry.dart';
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
      print("${user.username} sent a request to $selectedResult");
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
  const ProfileScreen({super.key});

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

  FirestoreService FS = FirestoreService();
  late Future<List<LeaderboardEntry>> leaderboardEntries;

  @override
  void initState() {
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa");
    super.initState();
    checkLoginStatus();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    leaderboardEntries = FS.getLeaderboard(user!.uid, 'allPoints');
    print("Friends: " + leaderboardEntries.toString());
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
              itemCount: getUserInfo().length,
              itemBuilder: (context, index) {
                final item = getUserInfo()[index];

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
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: leaderboardEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No leaderboard entries.'));
                } else {
                  return ListView(
                    children: snapshot.data!.map((LeaderboardEntry entry) {
                      return LeaderboardItem(
                        imageUrl: "assets/Dog3.jpg", // Replace with image URL
                        username: entry.username,
                        points: entry.points,
                      );
                    }).toList(),
                  );
                }
              },
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

//deprecated
  final List<Map<String, dynamic>> items = [
    {'type': 'text', 'data': "Joshua Uys"},
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

  getUserInfo() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    List<Map<String, dynamic>> items = [
      {'type': 'text', 'data': user!.username},
      {
        'type': 'image',
        'data':
            'https://upload.wikimedia.org/wikipedia/commons/4/41/Profile-720.png',
      },
      {'type': 'text', 'data': 'Friends'},
      {
        'type': 'picture',
        'data':
            'https://previews.123rf.com/images/happyvector071/happyvector0711904/happyvector071190414500/120957417-creative-illustration-of-default-avatar-profile-placeholder-isolated-on-background-art-design-grey.jpg',
      },
    ];
    return items;
  }
}

class LeaderboardItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final int points;

  const LeaderboardItem({
    Key? key,
    required this.imageUrl,
    required this.username,
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
                  username,
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
