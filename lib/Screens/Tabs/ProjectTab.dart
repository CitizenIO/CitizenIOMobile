import 'dart:io';
import 'package:CitizenIO/Screens/Home.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Components/ProjectField.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import '../../Database/DbManager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../SelectLatLng.dart';

class ProjectTab extends StatefulWidget {
  @override
  _ProjectTabState createState() => _ProjectTabState();
}

class _ProjectTabState extends State<ProjectTab> {
  TextEditingController leaderController = TextEditingController();
  TextEditingController headlineController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController prizeController = TextEditingController();
  TextEditingController donationGoalController = TextEditingController();
  TextEditingController volunteerGoalController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool donationsAccepted = false;
  Timestamp startDate = Timestamp.now();
  final picker = ImagePicker();
  List<Widget> imageSliders = [];
  bool slideShowVisible = false;
  bool singleImageVisible = false;
  String _date = "Not Set";

  List imgList = [
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  ];

  @override
  void initState() {
    super.initState();
    setState(() {});
    imageSliders = imgList
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
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Future addImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var image = File(pickedFile.path);
      if (image != null) {
        DatabaseManager manager = DatabaseManager();
        var urls = await manager.getImageURL(image, Timestamp.now());
        setState(() {
          imgList = urls;
          imageSliders = imgList
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
                      ),
                    ),
                  ),
                ),
              )
              .toList();
        });
        if (urls.length == 1) {
          singleImageVisible = true;
          slideShowVisible = false;
        } else {
          singleImageVisible = false;
          slideShowVisible = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      40,
                      30,
                      0,
                      30,
                    ),
                    child: Text("Start an Initiative",
                        style: TextStyle(
                          fontFamily: 'Nexa',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Get photo");
                      addImage();
                    },
                    child: Icon(Icons.add_a_photo),
                  ),
                ],
              ),
              Visibility(
                visible: singleImageVisible,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Container(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imgList[0],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width - 30,
                        height: 250,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: slideShowVisible,
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
              ProjectField(
                  controller: leaderController, placeholder: 'Your name'),
              ProjectField(
                  controller: headlineController,
                  placeholder: 'Project headline'),
              ProjectField(
                  controller: descriptionController,
                  placeholder: 'Project description'),
              ProjectField(controller: cityController, placeholder: 'City'),
              ProjectField(controller: prizeController, placeholder: 'Prize'),
              ProjectField(
                  controller: volunteerGoalController,
                  placeholder: 'Volunteer Goal'),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 0, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: donationsAccepted,
                      onChanged: (bool value) {
                        setState(() {
                          donationsAccepted = value;
                        });
                      },
                    ),
                    Text(
                      "Donations Accepted",
                      style: TextStyle(fontFamily: 'Nexa'),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: donationsAccepted,
                child: ProjectField(
                  controller: donationGoalController,
                  placeholder: 'Donation Goal',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showDatePicker(
                      context,
                      theme: DatePickerTheme(
                        containerHeight: 210.0,
                      ),
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime(2030, 12, 31),
                      onConfirm: (date) {
                        print('confirm $date');
                        _date = '${date.year} - ${date.month} - ${date.day}';
                        startDate = Timestamp.fromDate(date);
                        print("Start date: ${startDate.toDate().toString()}");
                        setState(() {});
                      },
                      currentTime: DateTime.now(),
                      locale: LocaleType.en,
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 18.0,
                                    color: Color(0xFF4f83c2),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 2, left: 3),
                                    child: Text(
                                      " $_date",
                                      style: TextStyle(
                                        color: Color(0xFF4f83c2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        fontFamily: 'Nexa',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "  Change",
                            style: TextStyle(
                              color: Color(0xFF4f83c2),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nexa',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectLocationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.map,
                                    size: 18.0,
                                    color: Color(0xFF4f83c2),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 2, left: 3),
                                    child: Text(
                                      "Location",
                                      style: TextStyle(
                                        color: Color(0xFF4f83c2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        fontFamily: 'Nexa',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "  Change",
                            style: TextStyle(
                              color: Color(0xFF4f83c2),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nexa',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 10),
                child: SizedBox(
                  child: ProgressButton(
                    color: Color(0xFFf6f5fb),
                    borderRadius: 22,
                    defaultWidget: Container(
                      width: 197,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF8156f9),
                            Color(0xFFa78bf9),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Upload Project',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nexa',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    progressWidget: const CircularProgressIndicator(),
                    width: 196,
                    height: 40,
                    onPressed: () async {
                      print("Upload post");
                      DatabaseManager manager = DatabaseManager();
                      if (donationsAccepted == true) {
                        await manager.uploadProject(
                          headlineController.text,
                          descriptionController.text,
                          leaderController.text,
                          prizeController.text,
                          startDate,
                          cityController.text,
                          donationsAccepted,
                          int.parse(donationGoalController.text),
                          int.parse(volunteerGoalController.text),
                        );
                      } else {
                        await manager.uploadProject(
                          headlineController.text,
                          descriptionController.text,
                          leaderController.text,
                          prizeController.text,
                          startDate,
                          cityController.text,
                          donationsAccepted,
                          0,
                          int.parse(volunteerGoalController.text),
                        );
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
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
