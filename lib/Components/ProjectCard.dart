import 'package:CitizenIO/Database/DbManager.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../Screens/ProjectDisplay.dart';
import 'package:share/share.dart';

class ProjectCard extends StatefulWidget {
  ProjectCard({
    this.project,
  });

  final Project project;

  @override
  _ProjectCardState createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _starred = false;
  var projectId;
  Color _starColor = Colors.grey;
  List<Color> volunteerColors = [
    Colors.pinkAccent[100],
    Colors.purpleAccent[200],
  ];
  bool verified = false;
  String volunteerText = 'Volunteer';
  bool volunteered = false;
  bool reported = false;
  TextEditingController donationAmount = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool showViewTasks = false;

  @override
  void initState() {
    super.initState();
    projectId = widget.project.projectId;
    DatabaseManager manager = DatabaseManager();
    Future.delayed(Duration.zero, () async {
      reported = await manager.hasReported(projectId);
      volunteered = await manager.isVolunteered(projectId);
      _starred = await manager.isStarred(projectId);
      if (volunteered) {
        setState(() {
          volunteerColors = [Colors.grey[300], Colors.grey[700]];
          volunteerText = 'Unvolunteer';
        });
      }
      if (widget.project.numberOfStars == 0) {
        setState(() {
          _starColor = Colors.grey;
        });
      }
    });
  }

  shareProject() {
    Share.share('http://34.93.56.182/home?id=$projectId');
  }

  Widget donationPopUp(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Donate',
        style: TextStyle(
          fontFamily: 'Nexa',
          color: Color(0xFF8bbaf5),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Enter the amount you want to donate."),
          TextField(
            // textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Nexa',
              fontWeight: FontWeight.bold,
            ),
            controller: donationAmount,
            cursorColor: Color(0xFF50fa7b),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 10, left: 20),
              hintText: 'Enter donation ammount',
              hintStyle: TextStyle(
                fontFamily: 'Nexa',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              fillColor: Color(0xFF4b4266),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF8bbaf5),
                  width: 2,
                ),
              ),
              // enabledBorder: null,
              disabledBorder: null,
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text(
            'Cancel',
          ),
        ),
        RaisedButton(
          color: Colors.blue[300],
          onPressed: () async {
            Navigator.of(context).pop();
            DatabaseManager manager = DatabaseManager();
            await manager.donateProject(
              projectId,
              int.parse(donationAmount.text),
            );
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text(
            'Confirm',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDisplay(project: widget.project),
            ),
          );
        },
        onLongPress: () {
          // Share this project
          shareProject();
        },
        child: Container(
          height: widget.project.donationsAccepted ? 477 : 442,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.45),
                spreadRadius: 7.5,
                blurRadius: 7,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        widget.project.referenceImages.first,
                        width: 400,
                        height: 203,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Container(
                      width: 57,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              DatabaseManager manager = DatabaseManager();
                              if (_starred == false) {
                                await manager.star(projectId);
                              } else {
                                await manager.unStar(projectId);
                              }
                              _starred = await manager.isStarred(projectId);
                              if (widget.project.numberOfStars == 0) {
                                setState(() {
                                  _starColor = Colors.grey;
                                });
                              } else {
                                if (_starred == true) {
                                  setState(() {
                                    _starColor = Colors.amber;
                                  });
                                } else {
                                  setState(() {
                                    _starColor = Colors.grey;
                                  });
                                }
                              }
                            },
                            child: StreamBuilder(
                                stream:
                                    firestore.collection('Users').snapshots(),
                                // ignore: missing_return
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  var _isTrue = false;
                                  if (!snapshot.hasData ||
                                      auth.currentUser == null) {
                                    _starColor = Colors.grey;
                                  } else {
                                    var docs = snapshot.data.docs;

                                    docs.forEach((doc) {
                                      if (doc.id == auth.currentUser.uid) {
                                        List starredProjectIds =
                                            doc['StarredProjectIds'];
                                        starredProjectIds
                                            .forEach((projectIdInDb) {
                                          if (projectIdInDb == projectId) {
                                            _isTrue = true;
                                            _starColor = Colors.amber;
                                          } else if (projectIdInDb !=
                                              projectId) {
                                            _starColor = Colors.grey;
                                          } else {
                                            _starColor = Colors.grey;
                                          }
                                        });
                                      } else if (doc.id ==
                                          auth.currentUser.uid) {
                                        _starColor = Colors.grey;
                                      }
                                    });
                                  }
                                  if (_isTrue == true) {
                                    _starColor = Colors.amber;
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, top: 4.5),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.star,
                                        color: _starColor,
                                        size: 25,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              top: 4,
                            ),
                            child: Text(
                              "${widget.project.numberOfStars}",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nexa',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Visibility(
                        visible: !widget.project.verified,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 5,
                            top: 5,
                          ),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.orange[500],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Visibility(
                        visible: widget.project.verified,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 5,
                            top: 5,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.project.headline,
                  style: TextStyle(
                    fontFamily: 'Nexa',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'By : ',
                      style: TextStyle(
                        fontFamily: 'Nexa',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${widget.project.leader}",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Nexa',
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    Icon(
                      Icons.location_pin,
                      size: 20,
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    Text(
                      widget.project.city,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Nexa',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 42,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      widget.project.description,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Nexa',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 80,
                      animation: true,
                      lineHeight: 20.0,
                      animationDuration: 1500,
                      percent: widget.project.numberOfVolunteers /
                                  widget.project.volunteerGoal <=
                              1.0
                          ? widget.project.numberOfVolunteers /
                              widget.project.volunteerGoal
                          : 1.0,
                      center: Text(
                          '${widget.project.numberOfVolunteers} of ${widget.project.volunteerGoal} Volunteered'),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      linearGradient: LinearGradient(
                        colors: [
                          Colors.pinkAccent[100],
                          Colors.purpleAccent[400],
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.project.donationsAccepted,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width - 80,
                          animation: true,
                          lineHeight: 20.0,
                          animationDuration: 1500,
                          percent: widget.project.amountDonated /
                                      widget.project.donationGoal <=
                                  1.0
                              ? widget.project.amountDonated /
                                  widget.project.donationGoal
                              : 1.0,
                          center: Text(
                              '₹${widget.project.amountDonated} of ₹${widget.project.donationGoal} Goal'),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          linearGradient: LinearGradient(
                            colors: [
                              Colors.amberAccent,
                              Colors.orangeAccent,
                              Colors.orangeAccent[700]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.project.donationsAccepted ? 30 : 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: widget.project.donationsAccepted,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  donationPopUp(context),
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 35,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amberAccent,
                                    Colors.orangeAccent[400],
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22)),
                            child: Center(
                              child: Text(
                                "Donate",
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GestureDetector(
                        onTap: () {
                          DatabaseManager manager = DatabaseManager();
                          if (volunteered) {
                            manager.unVolunteerProject(projectId);
                          } else {
                            manager.volunteerProject(projectId);
                          }
                          setState(() {
                            volunteered = !volunteered;
                            volunteerColors = volunteered
                                ? [
                                    Colors.grey[300],
                                    Colors.grey[700],
                                  ]
                                : [
                                    Colors.pinkAccent[100],
                                    Colors.purpleAccent[200],
                                  ];
                            volunteerText =
                                volunteered ? 'Unvolunteer' : 'Volunteer';
                          });
                        },
                        child: Container(
                          width: 120,
                          height: 35,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: volunteerColors,
                              ),
                              borderRadius: BorderRadius.circular(22)),
                          child: Center(
                            child: Text(
                              volunteerText,
                              style: TextStyle(
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width - 60)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (reported == false) {
                              DatabaseManager manager = DatabaseManager();
                              await manager.reportProject(projectId);
                            } else {
                              DatabaseManager manager = DatabaseManager();
                              await manager.unReportProject(projectId);
                            }
                            setState(() {
                              reported = !reported;
                            });
                          },
                          child: Icon(Icons.flag, color: Colors.red),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${widget.project.reports.length}',
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
