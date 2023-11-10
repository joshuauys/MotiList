import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testmoti/models/user.dart';

import 'task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(MyUser user, Task task) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add({
      'dueDate': task.dateTime,
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
      'dueDate': task.dateTime,
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

  Future<List<Task>> getTasksForDay(MyUser user, DateTime selectedDate) async {
    try {
      final taskSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('dueDate', isGreaterThanOrEqualTo: selectedDate)
          .where('dueDate', isLessThan: selectedDate.add(Duration(days: 1)))
          .get();

      final tasks = taskSnapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
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
        .where('username', isLessThanOrEqualTo: username + '\uf8ff')
        .get();

    return usernameSnapshot.docs
        .map((doc) => MyUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendFriendRequest(MyUser currentUser, MyUser friendUser) async {
    await _firestore
        .collection('users')
        .doc(friendUser.uid)
        .collection('friendRequests')
        .doc(currentUser.uid)
        .set({'requesterUID': currentUser.uid});
  }

  Future<void> acceptFriendRequest(MyUser currentUser, MyUser friendUser) async {
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
    await
  }

  Future<List<MyUser>> getFriendRequests(MyUser user) async {
    final friendReqSnapshot =

  }

  Future<List<MyUser>> getFriends(MyUser user) async {
    final friendsSnapshot =

  }

}