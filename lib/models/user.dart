
class MyUser {

  late final String uid;
  late String username;

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