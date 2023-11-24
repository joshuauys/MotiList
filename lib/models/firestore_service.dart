import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MotiList/utils/todo_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MotiList/models/user.dart';

import 'task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MyUser> initializeUser(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    MyUser currentUser = MyUser(
        uid: FirebaseAuth.instance.currentUser!.uid,
        username: userData?['username'] as String);

    return currentUser;
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
    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add({
      'daysOfWeek': task.daysOfWeek,
      'name': task.title,
      'description': task.description,
      'category': task.category,
    });

    String taskID = docRef.id;
    //task.id = taskID;
    print(taskID);
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
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
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
        .where('username', isGreaterThanOrEqualTo: username!)
        .where('username', isLessThanOrEqualTo: '$username\uf8ff'!)
        .get();

    print("Usernames found: " + usernameSnapshot.docs.length.toString());
    return usernameSnapshot.docs
        .map((doc) => MyUser.fromMap(doc.data()))
        .toList();
  }

  Future<void> printUsernames(String username) async {
    List<MyUser> users = await searchForUserByUsername(username);
    for (var user in users) {
      print("Username found: ${user.username}");
    }
  }

  Future<void> sendFriendRequest(MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friendRequests')
        .doc(currentUser.uid)
        .set({'requesterUID': currentUser.uid});
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
}
