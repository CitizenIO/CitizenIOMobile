import 'package:CitizenIO/Components/ProjectField.dart';
import 'package:CitizenIO/Database/DbManager.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:CitizenIO/Model/Task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class CreateTaskScreen extends StatefulWidget {
  CreateTaskScreen({
    this.project,
  });

  final Project project;

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescriptionController = TextEditingController();
  TextEditingController repRewardController = TextEditingController();

  String _date = "Not Set";
  DateTime dueDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Task',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 35,
            ),
            ProjectField(
                controller: taskNameController, placeholder: 'Task Name'),
            ProjectField(
                controller: taskDescriptionController,
                placeholder: 'Task Description'),
            ProjectField(
                controller: repRewardController, placeholder: 'Rep Reward'),
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
                      _date = '${date.year} - ${date.month} - ${date.day}';
                      setState(() {
                        dueDate = date;
                      });
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
            SizedBox(
              height: 20,
            ),
            SizedBox(
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
                      'Create Task',
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
                  FocusScope.of(context).unfocus();
                  DatabaseManager manager = DatabaseManager();
                  await manager.createNewTask(
                    widget.project.projectId,
                    Task(
                      name: taskNameController.text,
                      description: taskDescriptionController.text,
                      dueDate: Timestamp.fromDate(dueDate),
                      isComplete: false,
                      repReward: int.parse(repRewardController.text),
                      uploadDate: Timestamp.now(),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
