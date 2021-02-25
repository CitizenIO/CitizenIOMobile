import 'package:CitizenIO/Database/DbManager.dart';
import 'package:CitizenIO/Database/ReputationManager.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:CitizenIO/Model/Task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  TaskCard({
    this.project,
    this.task,
  });

  final Project project;
  final Task task;

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  IconData currentIcon = Icons.check_box_outline_blank_rounded;
  Color iconColor = Colors.grey;
  bool isAdmin = false;
  bool isChecked = false;
  TextEditingController volunteerOptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    if (widget.project.uid == auth.currentUser.uid) {
      isAdmin = true;
    }
    Future.delayed(Duration.zero, () async {
      DatabaseManager manager = DatabaseManager();
      isChecked = await manager.taskIsComplete(
          widget.project.projectId, widget.task.id);
      if (isChecked) {
        setState(() {
          currentIcon = Icons.check_box_rounded;
          iconColor = Colors.green;
        });
      } else {
        setState(() {
          currentIcon = Icons.check_box_outline_blank_rounded;
          iconColor = Colors.grey;
        });
      }
    });
  }

  creditRep() async {
    List<Widget> widgets = [];
    widget.project.volunteers.forEach(
      (element) async {
        widgets.add(
          GestureDetector(
            onTap: () {},
            child: Text(
              element,
              style: TextStyle(
                fontFamily: 'Nexa',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Flexible(
          child: Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  'Volunteers\n',
                  style: TextStyle(
                    fontFamily: 'Nexa',
                  ),
                ),
                SizedBox(
                  height: 71,
                  width: 200,
                  child: ListView(
                    children: widgets,
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 200,
                  child: TextField(
                    style: TextStyle(
                      fontFamily: 'Nexa',
                    ),
                    controller: volunteerOptionController,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            height: 30,
            width: 200,
            child: FlatButton(
              onPressed: () async {
                Navigator.of(context).pop();
                DatabaseManager manager = DatabaseManager();

                manager.setTaskCompleted(
                    widget.project.projectId, widget.task.id);
                ReputationManager reputationManager = ReputationManager();
                String uid = await manager
                    .getUidFromName(volunteerOptionController.text);
                reputationManager.increaseRep(uid, widget.task.repReward);
                setState(() {
                  isChecked = true;
                });
                if (isChecked) {
                  setState(() {
                    currentIcon = Icons.check_box_rounded;
                    iconColor = Colors.green;
                  });
                } else {
                  setState(() {
                    currentIcon = Icons.check_box_outline_blank_rounded;
                    iconColor = Colors.grey;
                  });
                }
                volunteerOptionController.clear();
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Nexa',
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
            width: 100,
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Nexa'),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              spreadRadius: 3,
            )
          ],
        ),
        child: Stack(
          children: [
            Visibility(
              visible: isAdmin,
              child: GestureDetector(
                onTap: () async {
                  if (isChecked == false) {
                    creditRep();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                    left: 7,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Icon(
                      currentIcon,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.task.name,
                  style: TextStyle(
                    fontFamily: 'Nexa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.task.description,
                    style: TextStyle(
                      fontFamily: 'Nexa',
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 400,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Rep Reward",
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'Due Date',
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Upload Date',
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${widget.task.repReward} Rep",
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              widget.task.dueDate
                                  .toDate()
                                  .toString()
                                  .substring(0, 10),
                              style: TextStyle(
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            widget.task.uploadDate
                                .toDate()
                                .toString()
                                .substring(0, 10),
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// TODO: limit number of projects you can volunteer for
//
