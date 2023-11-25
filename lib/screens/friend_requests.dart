// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import '../models/user.dart';
//import 'package:MotiList/utils/leaderboard_widgets.dart';
import 'package:MotiList/models/firestore_service.dart';

import 'package:provider/provider.dart';

// FriendRequestsScreen widget
class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  FirestoreService firestoreService = FirestoreService();
  late Future<List<MyUser>> friendRequests;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      friendRequests = firestoreService.getFriendRequests(currentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: FutureBuilder<List<MyUser>>(
        future: friendRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No friend requests.'));
          } else {
            List<MyUser> requests = snapshot.data!;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                MyUser requestUser = requests[index];
                return ListTile(
                  title: Text(requestUser.username),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          // Accept friend request logic
                          firestoreService.acceptFriendRequest(
                            userProvider.currentUser!,
                            requestUser,
                          );
                          // Update the UI
                          setState(() {
                            friendRequests = firestoreService
                                .getFriendRequests(userProvider.currentUser!);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          // Deny friend request logic
                          firestoreService.denyFriendRequest(
                            userProvider.currentUser!,
                            requestUser,
                          );
                          // Update the UI
                          setState(() {
                            friendRequests = firestoreService
                                .getFriendRequests(userProvider.currentUser!);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
