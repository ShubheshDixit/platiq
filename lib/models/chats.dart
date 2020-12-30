import 'package:cloud_firestore/cloud_firestore.dart';

class Chats {
  final String senderId;
  final String photoUrl;
  final String msg;
  final List<dynamic> mediaUrls;
  final Timestamp time;
  final bool isLiked;
  final String flag;
  final bool isSeen;
  final String id;

  Chats(
      {this.senderId,
      this.photoUrl,
      this.msg,
      this.mediaUrls,
      this.time,
      this.isLiked,
      this.flag,
      this.isSeen,
      this.id});

  factory Chats.fromDocument(DocumentSnapshot doc) {
    return Chats(
      senderId: doc.get('senderId'),
      photoUrl: doc.get('photoUrl'),
      msg: doc.get('msg'),
      mediaUrls: doc.get('mediaUrls'),
      time: doc.get('timestamp'),
      isLiked: doc?.get('isLiked'),
      flag: doc.get('flag'),
      isSeen: doc.get('isSeen'),
      id: doc.get('id'),
    );
  }
}
