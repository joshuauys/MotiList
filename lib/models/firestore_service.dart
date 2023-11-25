// ignore_for_file: avoid_print

import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MotiList/models/user.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:MotiList/utils/todo_widgets.dart';
import 'leaderboard_entry.dart';
import 'task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MyUser> initializeUser(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    MyUser currentUser =
        MyUser(uid: uid, username: userData?['username'] as String);

    return currentUser;
  }

  Future<void> initializePoints(MyUser newUser) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('fitness')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('academic')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('health')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('finance')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('career')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('hobbies')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('other')
        .set({'points': 0});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(newUser.uid)
        .collection('points')
        .doc('all')
        .set({'points': 0});
  }

//Meant to convert a TodoItem to a Task, not sure if this is the place to add it since
//it isnt directly related to firestore, but it works for now
  Task convertTodoItemToTask(TodoItem todoItem) {
    return Task(
      title: todoItem.title,
      description: todoItem.description,
      category: todoItem.category,
      daysOfWeek: todoItem.weekDaysChecked,
    );
  }

  Future<void> addUsername(MyUser user, String username) async {
    await _firestore.collection('users').doc(user.uid).set({
      'username': username, // Replace with the actual username
    }, SetOptions(merge: true));
  }

  Future<void> addUid(MyUser user, String uid) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': uid, // Replace with the actual username
    }, SetOptions(merge: true));
  }

  Future<void> createTask(MyUser user, Task task) async {
    await _firestore.collection('users').doc(user.uid).collection('tasks').add({
      'daysOfWeek': task.daysOfWeek,
      'name': task.title,
      'description': task.description,
      'category': task.category,
    });
  }

  Future<void> editTask(MyUser user, String taskID, Task task) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskID)
        .update({
      'daysOfWeek': task.daysOfWeek,
      'name': task.title,
      'description': task.description,
      'category': task.category,
    });
  }

  Future<void> deleteTask(MyUser user, String taskID) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskID)
        .delete();
  }

  Future<Task> getTask(MyUser user, String taskID) async {
    final taskSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskID)
        .get();

    final task = Task.fromMap(taskSnapshot.data() as Map<String, dynamic>);

    return task;
  }

  Future<List<Task>> getTasksForDay(MyUser user, String selectedDay) async {
    try {
      final taskSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .get();

      final tasks = taskSnapshot.docs
          .map((doc) => Task.fromMap(doc.data()))
          .where((task) => task.daysOfWeek[selectedDay] == true)
          .toList();

      return tasks;
    } catch (e) {
      return [];
    }
  }

  Future<List<MyUser>> searchForUserByUsername(String username) async {
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .where('username', isLessThanOrEqualTo: '$username\uf8ff')
        .get();

    return usernameSnapshot.docs
        .map((doc) => MyUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> getUidfromUsername(String username) async {
    List<MyUser> users = await searchForUserByUsername(username);
    String uid = "";
    for (var user in users) {
      uid = user.uid;
    }
    return uid;
  }

  Future<void> sendFriendRequest(MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friendRequests')
        .doc(currentUser
            .uid) // This sets the document ID to the currentUser's UID
        .set({
      'requesterUID': currentUser.uid
    }); // This stores the requester's UID
  }

  Future<void> sendFriendRequestByUsername(
      MyUser currentUser, String username) async {
    try {
      String uid = await getUidfromUsername(username);

      if (uid.isNotEmpty) {
        MyUser foundUser = await initializeUser(uid);

        await sendFriendRequest(currentUser, foundUser);
      } else {
        print("User not found.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  Future<void> acceptFriendRequest(
      MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friendRequests')
        .doc(currentUser.uid)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friends')
        .doc(currentUser.uid)
        .set({'friendUID': currentUser.uid});

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .doc(friendUser.uid)
        .set({'friendUID': friendUser.uid});
  }

  Future<void> denyFriendRequest(MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .doc(friendUser.uid)
        .delete();
  }

  Future<void> removeFriend(MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .doc(friendUser.uid)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friends')
        .doc(currentUser.uid)
        .delete();
  }

  Future<List<MyUser>> getFriendRequests(MyUser user) async {
    final friendReqSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .get();

    final friendReqUids = friendReqSnapshot.docs.map((doc) => doc.id).toList();

    // Retrieve user profiles from friendRequestUids.
    final users = await Future.wait(
      friendReqUids.map(
        (uid) => _firestore.collection('users').doc(uid).get(),
      ),
    );

    return users
        .map((doc) => MyUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<MyUser>> getFriends(MyUser user) async {
    final friendsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .get();

    final friendUids = friendsSnapshot.docs.map((doc) => doc.id).toList();

    // Retrieve user profiles from friendUids.
    final users = await Future.wait(
      friendUids.map(
        (uid) => _firestore.collection('users').doc(uid).get(),
      ),
    );

    return users
        .map((doc) => MyUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> printFriendRequests(MyUser user) async {
    final friendReqSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .get();

    final friendReqUids = friendReqSnapshot.docs.map((doc) => doc.id).toList();
    print(friendReqUids);
    // Retrieve user profiles from friendRequestUids.
    final usersSnapshots = await Future.wait(
      friendReqUids.map(
        (uid) => _firestore.collection('users').doc(uid).get(),
      ),
    );

    // Convert snapshots to MyUser objects.
    final users = usersSnapshots.map((snapshot) {
      final data = snapshot.data();
      return MyUser.fromMap(data!); // Assuming data is not null.
    }).toList();

    // Print the usernames.
    for (var user in users) {
      print('Friend request from: ${user.username}');
    }
  }

  Future<void> updatePoints(String uid, String category) async {
    DocumentReference categoryRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('points')
        .doc(category);

    DocumentSnapshot<Map<String, dynamic>> categorySnapshot =
        await categoryRef.get() as DocumentSnapshot<Map<String, dynamic>>;

    int currentPoints = categorySnapshot.exists
        ? (categorySnapshot.data()?['points'] as int?) ?? 0
        : 0;

    // Update points for the category
    await categoryRef.set({'points': currentPoints + 1});

    // Update 'allPoints' by fetching all category points and summing them
    QuerySnapshot<Map<String, dynamic>> allPointsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('points')
        .get();

    int allPoints = allPointsSnapshot.docs
        .map((doc) => (doc.data()['points'] as int?) ?? 0)
        .fold(0, (previous, current) => previous + current);

    // Update 'allPoints' in the same 'points' document
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('points')
        .doc('allPoints')
        .set({'points': allPoints});
  }

  Future<List<LeaderboardEntry>> getLeaderboard(
      String uid, String category) async {
    // Fetch user's friends
    QuerySnapshot<Map<String, dynamic>> friendsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();

    List<String> friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();

    // Fetch current user's points for the given category
    DocumentSnapshot<Map<String, dynamic>> currentUserPointsSnapshot =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('points')
            .doc(category)
            .get();

    int currentUserPoints = currentUserPointsSnapshot.data()?['points'] ?? 0;

    // Fetch current user's username
    DocumentSnapshot<Map<String, dynamic>> currentUserSnapshot =
        await _firestore.collection('users').doc(uid).get();

    String currentUsername = currentUserSnapshot.data()?['username'] ??
        ""; // Change 'username' to the actual field name

    // Create LeaderboardEntry object for the current user
    LeaderboardEntry currentUserEntry =
        LeaderboardEntry(username: currentUsername, points: currentUserPoints);

    // Fetch friend points for the given category
    List<LeaderboardEntry> friendEntries = [];
    for (String friendId in friendIds) {
      DocumentSnapshot<Map<String, dynamic>> friendPointsSnapshot =
          await _firestore
              .collection('users')
              .doc(friendId)
              .collection('points')
              .doc(category)
              .get();

      // Fetch the friend's username
      DocumentSnapshot<Map<String, dynamic>> friendUserSnapshot =
          await _firestore.collection('users').doc(friendId).get();

      if (friendPointsSnapshot.exists && friendUserSnapshot.exists) {
        Map<String, dynamic> pointsData = friendPointsSnapshot.data() ?? {};
        Map<String, dynamic> userData = friendUserSnapshot.data() ?? {};

        int points = pointsData['points'] ?? 0;
        String username = userData['username'] ??
            ""; // Change 'username' to the actual field name

        friendEntries.add(LeaderboardEntry(username: username, points: points));
      }
    }

    // Insert the current user's entry into the correct position in the friendEntries list
    int currentUserIndex =
        friendEntries.indexWhere((entry) => entry.points < currentUserPoints);
    if (currentUserIndex == -1) {
      // If the current user has the highest or equal points, add to the beginning
      friendEntries.insert(0, currentUserEntry);
    } else {
      friendEntries.insert(currentUserIndex, currentUserEntry);
    }

    return friendEntries;
  }
}
