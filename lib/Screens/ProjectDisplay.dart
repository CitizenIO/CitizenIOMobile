import 'package:CitizenIO/Database/DbManager.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:CitizenIO/Screens/Chat/ChatScreen.dart';
import 'package:CitizenIO/Screens/TaskDisplay.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import './DisplayLatLng.dart';

class ProjectDisplay extends StatefulWidget {
  ProjectDisplay({
    this.project,
  });

  final Project project;

  @override
  _ProjectDisplayState createState() => _ProjectDisplayState();
}

class _ProjectDisplayState extends State<ProjectDisplay> {
  Project project;
  String headline;
  String description;
  String leader;
  String prize;
  int amountDonated;
  int donationGoal;
  int numberOfVolunteers;
  List volunteers;
  Map donators;
  Timestamp startDate;
  List referenceImages;
  List timeLineItems;
  String city;
  GeoPoint location;
  bool donationsAccepted;
  int volunteerGoal;
  List<Widget> imageSliders = [];
  bool isCarousel = false;
  List<Color> volunteerColors = [
    Colors.pinkAccent[100],
    Colors.purpleAccent[200],
  ];
  String volunteerText = 'Volunteer';
  bool volunteered = false;
  bool reported = false;
  bool showTaskListButton = false;

  TextEditingController donationAmount = TextEditingController();

  Widget donationPopUp(BuildContext context) {
    return new AlertDialog(
      title: const Text(
        'Donate',
        style: TextStyle(
          fontFamily: 'Nexa',
          color: Color(0xFF8bbaf5),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: new Column(
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
            print("Project id is ${widget.project.projectId}");
            print("Donation amount is ${donationAmount.text}");
            await manager.donateProject(
              widget.project.projectId,
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
  void initState() {
    super.initState();
    project = widget.project;
    headline = project.headline;
    description = project.description;
    leader = project.leader;
    prize = project.prize;
    amountDonated = project.amountDonated;
    donationGoal = project.donationGoal;
    numberOfVolunteers = project.numberOfVolunteers;
    volunteers = project.volunteers;
    donators = project.donators;
    startDate = project.startDate;
    referenceImages = project.referenceImages;
    city = project.city;
    donationsAccepted = project.donationsAccepted;
    volunteerGoal = project.volunteerGoal;
    location = project.location;

    DatabaseManager manager = DatabaseManager();
    Future.delayed(Duration.zero, () async {
      volunteered = await manager.isVolunteered(widget.project.projectId);
      if (volunteered) {
        setState(() {
          volunteerColors = [Colors.grey[300], Colors.grey[700]];
          volunteerText = 'Unvolunteer';
        });
      }
    });

    if (referenceImages.length > 1) {
      isCarousel = true;
    } else {
      isCarousel = false;
    }

    imageSliders = referenceImages
        .map(
          (item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    ],
                  )),
            ),
          ),
        )
        .toList();

    showTaskListButton =
        manager.getTaskLength(widget.project.projectId) == 0 ? false : true;

    FirebaseAuth auth = FirebaseAuth.instance;

    if (showTaskListButton == true) {
      showTaskListButton = widget.project.uid == auth.currentUser.uid;
    }
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
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: !isCarousel,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Container(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        referenceImages[0],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width - 30,
                        height: 250,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isCarousel,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                    items: imageSliders,
                  ),
                ),
              ),
              Text(
                headline,
                style: TextStyle(
                  fontFamily: 'Nexa',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'By : ',
                    style: TextStyle(
                      fontFamily: 'Nexa',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    leader,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Nexa',
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Open location in map
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayMapView(
                            goto: LatLng(location.latitude, location.longitude),
                            project: project,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 30,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 2.0,
                          ),
                          Text(
                            city,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nexa',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Nexa',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
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
              ),
              Visibility(
                visible: widget.project.donationsAccepted,
                child: Padding(
                  padding: EdgeInsets.only(top: 15),
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
                height: 30,
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Text(
                              "Volunteers",
                              style: TextStyle(
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Container(
                              height: 70,
                              child: ListView.builder(
                                itemCount: volunteers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 20,
                                    child: Text(
                                      volunteers[index],
                                      style: TextStyle(
                                        fontFamily: 'Nexa',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Donators",
                            style: TextStyle(
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 70,
                            child: ListView.builder(
                              itemCount: donators.length,
                              itemBuilder: (BuildContext context, int index) {
                                var keys = donators.keys.toList();
                                var values = donators.values.toList();

                                return Container(
                                  height: 20,
                                  child: Row(
                                    children: [
                                      Text(
                                        '${keys[index]}: ',
                                        style: TextStyle(
                                          fontFamily: 'Nexa',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${values[index]}',
                                        style: TextStyle(
                                          fontFamily: 'Nexa',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
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
                            manager
                                .unVolunteerProject(widget.project.projectId);
                          } else {
                            manager.volunteerProject(widget.project.projectId);
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
              ),
              Visibility(
                visible: volunteered,
                child: Visibility(
                  visible: showTaskListButton,
                  child: SizedBox(
                    width: 150,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskListScreen(
                              project: widget.project,
                            ),
                          ),
                        );
                      },
                      color: Color(0xFF8bbaf5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'View Tasks',
                        style: TextStyle(
                          fontFamily: 'Nexa',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              CommentSection(project: widget.project),
            ],
          ),
        ),
      ),
    );
  }
}
