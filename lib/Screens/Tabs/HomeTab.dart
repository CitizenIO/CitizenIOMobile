import 'package:CitizenIO/Components/ProjectCard.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String filter = 'None';
  String currentSearchQuery = '';
  List<String> filters = [
    'Newest To Oldest',
    'Most Popular',
    'Starred Projects',
  ];

  Stream<QuerySnapshot> getFilteredSnapshots(String query) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection('Projects')
        .where('Headline', isGreaterThanOrEqualTo: query)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40,
                width: 375,
                child: Material(
                  elevation: 7.0,
                  shadowColor: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    onChanged: (String query) {
                      setState(() {
                        currentSearchQuery = query;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.only(bottom: 1, right: 10),
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                stream: currentSearchQuery == ''
                    ? firestore.collection('Projects').snapshots()
                    : getFilteredSnapshots(currentSearchQuery),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData || auth.currentUser == null) {
                    return Container();
                  } else {
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data.docs.map((
                        QueryDocumentSnapshot document,
                      ) {
                        var data = document.data();
                        if (data != null) {
                          if (document.id != 'ProjectIds') {
                            return ProjectCard(
                              project: Project(
                                projectId: data['ProjectId'],
                                headline: data['Headline'],
                                description: data['Description'],
                                leader: data['Leader'],
                                prize: data['Prize'],
                                city: data['City'],
                                numberOfVolunteers: data['NumberOfVolunteers'],
                                volunteerGoal: data['VolunteerGoal'],
                                amountDonated: data['AmountDonated'],
                                donationGoal: data['DonationGoal'],
                                donationsAccepted: data['DonationsAccepted'],
                                numberOfStars: data['NumberOfStars'],
                                location: data['Location'],
                                startDate: data['StartDate'],
                                donators: data['Donators'],
                                referenceImages: data['ReferenceImages'],
                                uid: data['Uid'],
                                volunteers: data['Volunteers'],
                                verified: data['Verified'],
                                reports: data['Reports'],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }).toList(),
                    );
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* 
TODO:
    - Improve share
    - Add user profile display
*/
