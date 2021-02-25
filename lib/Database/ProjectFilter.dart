import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectFilter {
  Query latestToOldest() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('Projects').orderBy('StartDate');
  }

  Query mostStarred() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore.collection('Projects').orderBy('NumberOfStars');
  }

  List currentlyStarred() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    List starred = [];
    firestore
        .collection('Users')
        .doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      Map data = snapshot.data();
      starred = data['StarredProjectIds'];
    });
    return starred;
  }
}
