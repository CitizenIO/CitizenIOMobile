import 'package:cloud_firestore/cloud_firestore.dart';

class ReputationManager {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> getCurrentRep(String userId) async {
    int returnVal;
    DocumentReference userRef = firestore.collection('Users').doc(userId);
    await userRef.get().then((DocumentSnapshot snap) {
      print('SOMETHING ${snap.data()['Reputation']}');
      returnVal = snap.data()['Reputation'];
    });
    return returnVal;
  }

  increaseRep(String userId, int reputation) async {
    DocumentReference userRef = firestore.collection('Users').doc(userId);
    int updatedRep;
    int currentRep = await getCurrentRep(userId);
    updatedRep = currentRep + reputation;
    userRef.update({
      'Reputation': updatedRep,
    });
  }

  decreaseRep(String userId, int reputation) async {
    DocumentReference userRef = firestore.collection('Users').doc(userId);
    int updatedRep;
    int currentRep = await getCurrentRep(userId);
    print('The current reputation is $currentRep');

    updatedRep = currentRep - reputation;
    userRef.update({
      'Reputation': updatedRep,
    });
  }
}
