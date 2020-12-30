import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String username;
  final String id;
  final String email;
  final String mobile;
  final String photoUrl;
  final bool isON;
  final String chatId;

  Friend({
    this.username,
    this.id,
    this.email,
    this.mobile,
    this.photoUrl,
    this.isON,
    this.chatId,
  });

  factory Friend.fromDocument(DocumentSnapshot doc) {
    return Friend(
        username: doc.get('username'),
        id: doc.get('id'),
        email: doc.get('email'),
        mobile: doc.get('mobile'),
        photoUrl: doc.get('photoUrl'),
        isON: doc.get('online'),
        chatId: doc.get('chatId'));
  }
}
