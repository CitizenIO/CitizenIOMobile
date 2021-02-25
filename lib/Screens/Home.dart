import 'package:flutter/material.dart';
import './Tabs/LeaderBoard.dart';
import 'LoadingScreen.dart';
import 'Tabs/ProjectTab.dart';
import './Tabs/HomeTab.dart';
import 'dart:math';
import './LoadingScreen.dart';
import './Tabs/ProfileTab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _tab = HomeTab();
  Color leaderboardTabItemColor = Color(0xFFb4b4b9);
  Color homeTabItemColor = Color(0xFF7747fd);
  Color profileTabItemColor = Color(0xFFb4b4b9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Transform.rotate(
        angle: pi / 4,
        child: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(),
              ),
            );
            setState(() {
              leaderboardTabItemColor = Color(0xFFb4b4b9);
              homeTabItemColor = Color(0xFFb4b4b9);
              _tab = ProjectTab();
            });
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8156f9),
                  Color(0xFFa78bf9),
                ],
              ),
            ),
            child: Icon(
              Icons.close,
              size: 20,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.5),
              child: IconButton(
                icon: Icon(Icons.home),
                color: homeTabItemColor,
                onPressed: () {
                  setState(() {
                    leaderboardTabItemColor = Color(0xFFb4b4b9);
                    homeTabItemColor = Color(0xFF7747fd);
                    profileTabItemColor = Color(0xFFb4b4b9);
                    _tab = HomeTab();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.5),
              child: IconButton(
                color: leaderboardTabItemColor,
                icon: Icon(
                  Icons.leaderboard,
                ),
                onPressed: () {
                  setState(() {
                    leaderboardTabItemColor = Color(0xFF7747fd);
                    homeTabItemColor = Color(0xFFb4b4b9);
                    profileTabItemColor = Color(0xFFb4b4b9);
                    _tab = ReputationLeaderboard();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.5),
              child: IconButton(
                color: profileTabItemColor,
                icon: Icon(Icons.person),
                onPressed: () {
                  setState(() {
                    leaderboardTabItemColor = Color(0xFFb4b4b9);
                    profileTabItemColor = Color(0xFF7747fd);
                    homeTabItemColor = Color(0xFFb4b4b9);
                    _tab = ProfileTab();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
