import 'package:cloud_firestore/cloud_firestore.dart';

class ChatManager {
  uploadComment(
      String projectId, String message, Timestamp timestamp, String senderUid) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference ref =
        firestore.collection('Projects').doc(projectId).collection('Comments');
    ref.add({
      'Message': message,
      'UploadTime': timestamp,
      'SenderUid': senderUid,
    });
  }
}
