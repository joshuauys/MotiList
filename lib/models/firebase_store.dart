import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStore {
  final storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> uploadProfilePicture(String userId, String imagePath) async {
      final ref = storage.ref().child('profile_pictures/$userId.jpg');
      final uploadTask = ref.putFile(File(imagePath));

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the user's document with the new profile picture URL
      await updateProfilePictureUrl(userId, downloadUrl);

      return downloadUrl;
  }

  Future<void> updateProfilePictureUrl(String userId, String pictureUrl) async {
      await firestore.collection('users').doc(userId).update({
        'profilePictureUrl': pictureUrl});
  }

  Future<void> deleteProfilePicture(String userId) async {
      final ref = storage.ref().child('profile_pictures/$userId.jpg');
      await ref.delete();

      // this updates the url stored in the user document in firestore to the
      // blank url
      await updateProfilePictureUrl(userId,
          'https://iio.azcast.arizona.edu/sites/default/files/profile-blank-whitebg.png');
  }

}