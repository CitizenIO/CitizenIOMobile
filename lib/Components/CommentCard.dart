import 'package:CitizenIO/Model/Comment.dart';
import 'package:CitizenIO/Screens/Tabs/ProfileTab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  CommentCard({
    this.comment,
  });

  final Comment comment;

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String username = '';
  String reputation = '';
  String numStarProj = '';
  String numVolProj = '';
  String numProj = '';
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      username = await getUserName(widget.comment.senderUid);
      reputation = await getReputation(widget.comment.senderUid);
      numStarProj = await getStarCount(widget.comment.senderUid);
      numVolProj = await getVolunteerCount(widget.comment.senderUid);
      numProj = await getNumberOfProjects(widget.comment.senderUid);
      date = widget.comment.uploadTime.toDate();
      setState(() {});
    });
  }

  Future<String> getUserName(String uid) async {
    String username;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      username = snapshot.data()['UserName'];
    });
    return username;
  }

  Future<String> getReputation(String uid) async {
    String rep;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      rep = snapshot.data()['Reputation'].toString();
    });
    return rep;
  }

  Future<String> getStarCount(String uid) async {
    String numStarProj;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      numStarProj = snapshot.data()['StarredProjectCount'].toString();
    });
    return numStarProj;
  }

  Future<String> getVolunteerCount(String uid) async {
    String numVolProj;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      numVolProj = snapshot.data()['VolunteeringProjectCount'].toString();
    });
    return numVolProj;
  }

  Future<String> getNumberOfProjects(String uid) async {
    String numProj;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      numProj = snapshot.data()['ProjectIds'].length.toString();
    });
    return numProj;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileTab(uid: widget.comment.senderUid),
                    ),
                  );
                },
                child: Container(
                  width: 125,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          username,
                          style: TextStyle(
                            fontFamily: 'Nexa',
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        '$reputation Rep',
                        style: TextStyle(
                          fontFamily: 'Nexa',
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$numProj',
                              style: TextStyle(
                                fontFamily: 'Nexa',
                              ),
                            ),
                            SizedBox(
                              width: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Icon(
                                Icons.notes,
                                size: 15,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '$numStarProj',
                              style: TextStyle(
                                fontFamily: 'Nexa',
                              ),
                            ),
                            SizedBox(
                              width: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: Icon(
                                Icons.star,
                                size: 15,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '$numVolProj',
                              style: TextStyle(
                                fontFamily: 'Nexa',
                              ),
                            ),
                            SizedBox(
                              width: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3.0),
                              child: Icon(
                                Icons.person,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 2,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              widget.comment.message,
                              style: TextStyle(
                                fontFamily: 'Nexa',
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 50,
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 10,
                            ),
                            child: Text(
                              '${date.year} - ${date.month} - ${date.day}',
                              style: TextStyle(
                                color: Color(0xFF4f83c2),
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                fontFamily: 'Nexa',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
