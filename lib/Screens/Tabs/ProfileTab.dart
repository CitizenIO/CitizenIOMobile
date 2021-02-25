import 'package:CitizenIO/Components/ProjectCard.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Database/DbManager.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({
    this.uid,
  });

  final String uid;

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  var userDoc;
  var projectDoc;
  String username = 'loading..';
  int reputation = 0;
  List projectIds = [];
  String projectId = '';
  String headline = '';
  String description = '';
  String leader = '';
  String prize = '';
  String city = '';
  int numberOfVolunteers = 0;
  int volunteerGoal = 0;
  int amountDonated = 0;
  int donationGoal = 0;
  bool donationsAccepted = false;
  int numberOfStars = 0;
  GeoPoint location = GeoPoint(12, 77);
  Timestamp startDate = Timestamp.now();
  List volunteers = [];
  Map donators = {};
  List referenceImages = [];
  List reports = [];
  bool verified = false;
  String uid = '';
  String starCount = '';
  String projectCount = '';
  String volunteerCount = '';

  String uidTemp;

  FirebaseAuth auth = FirebaseAuth.instance;

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
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.uid == null) {
        uidTemp = auth.currentUser.uid;
      } else {
        uidTemp = widget.uid;
      }
      starCount = await getStarCount(uidTemp);
      volunteerCount = await getVolunteerCount(uidTemp);
      projectCount = await getNumberOfProjects(uidTemp);
      DatabaseManager manager = DatabaseManager();
      userDoc = await manager.getUserDoc(uidTemp);
      print('doc is $userDoc');
      setState(() {
        username = userDoc['UserName'];
        reputation = userDoc['Reputation'];
        projectIds = userDoc['ProjectIds'];
      });
      projectIds.forEach((id) async {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Project Details",
          style: TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back, color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.amberAccent,
                        Colors.orangeAccent,
                      ]),
                      // color: Colors.amberAccent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            username,
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          '$reputation Rep',
                          style: TextStyle(
                            fontFamily: 'Nexa',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                            top: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$projectCount',
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontSize: 16,
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
                                '$starCount',
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Icon(
                                  Icons.star,
                                  size: 17,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '$volunteerCount',
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontSize: 16,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
