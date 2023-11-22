//import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  MyUser? _currentUser;

  MyUser? get currentUser => _currentUser;

  void setUser(MyUser user) {
    _currentUser = user;
    print(_currentUser!.username);
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}

/// Boundary class for a User object, implemented from Firebase
/// @authors Spencer Hoag & Zachary Hudelson
/// @version 1.0
class MyUser {
  late final String uid;
  late String username;

  /// User Objects
  /// @param uid User ID generated by firebase
  /// @param username Username of a User
  MyUser({required this.uid, required this.username});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(uid: map['uid'], username: map['username']);
  }
}
