import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String username;
  final String id;
  final String email;
  final String mobile;
  final String photoUrl;
  final bool isON;
  final bool darkMode;

  MyUser({
    this.username,
    this.id,
    this.email,
    this.mobile,
    this.photoUrl,
    this.isON,
    this.darkMode,
  });

  factory MyUser.fromDocument(DocumentSnapshot doc) {
    return MyUser(
      username: doc.get('username'),
      id: doc.get('id'),
      email: doc.get('email'),
      mobile: doc.get('mobile'),
      photoUrl: doc.get('photoUrl'),
      isON: doc.get('online'),
      darkMode: doc.get('darkMode'),
    );
  }
}
