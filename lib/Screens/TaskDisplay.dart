import 'package:CitizenIO/Components/TaskCard.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:CitizenIO/Model/Task.dart';
import 'package:CitizenIO/Screens/CreateTask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TaskListScreen extends StatefulWidget {
  TaskListScreen({
    this.project,
  });

  final Project project;

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool visible;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    print(auth.currentUser.uid);
    print(widget.project.uid);
    visible = auth.currentUser.uid == widget.project.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(
            fontFamily: 'Nexa',
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Visibility(
        visible: visible,
        child: Transform.rotate(
          angle: pi / 4,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
              right: 10.0,
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateTaskScreen(
                      project: widget.project,
                    ),
                  ),
                );
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
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Projects')
            .doc(widget.project.projectId)
            .collection('Tasks')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                return TaskCard(
                  project: widget.project,
                  task: Task(
                    id: document.id,
                    name: data['Name'],
                    description: data['Description'],
                    dueDate: data['DueDate'],
                    uploadDate: data['UploadDate'],
                    isComplete: data['IsComplete'],
                    repReward: data['RepReward'],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
