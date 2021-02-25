import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  Comment({
    this.message,
    this.senderUid,
    this.uploadTime,
  });

  final String senderUid;
  final String message;
  final Timestamp uploadTime;
}
