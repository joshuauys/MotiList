import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? getCurrentUser() {
  return FirebaseAuth.instance.currentUser;
}

final storage = FirebaseStorage.instance;
final storageRef = FirebaseStorage.instance.ref();
final pathReference = storageRef.child("profile.jpg");
final gsReference = FirebaseStorage.instance
    .refFromURL("gs://motilist-88199.appspot.com/Thumbs2.jpg");
final httpsReference = FirebaseStorage.instance
    .refFromURL("gs://motilist-88199.appspot.com/Thumbs2.jpg");

class myUser {
  final String displayName;
  final String email;
  final String profilePhotoUrl;

  myUser({
    required this.displayName,
    required this.email,
    required this.profilePhotoUrl,
  });
}
