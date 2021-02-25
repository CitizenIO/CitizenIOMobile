import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/AppUser.dart';
import '../../Components/UserCard.dart';

class ReputationLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Leaderboard",
          style: TextStyle(
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        // leading: GestureDetector(
        //     onTap: () {
        //       Navigator.of(context).pop();
        //     },
        //     child: Icon(Icons.arrow_back, color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Image.asset(
                'assets/images/trophy.gif',
                height: 220,
              ),
            ),
            Flexible(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .orderBy('Reputation', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView(
                      children: snapshot.data.docs.map((
                        QueryDocumentSnapshot document,
                      ) {
                        var data = document.data();
                        AppUser user = AppUser(
                          uid: document.id,
                          displayName: data['UserName'],
                          currentReputation: data['Reputation'],
                        );
                        return UserCard(
                          user: user,
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
