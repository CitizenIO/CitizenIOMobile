import 'package:CitizenIO/Components/CommentCard.dart';
import 'package:CitizenIO/Database/ChatManager.dart';
import 'package:CitizenIO/Model/Comment.dart';
import 'package:CitizenIO/Model/Project.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  CommentSection({
    this.project,
  });

  final Project project;

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Projects')
                          .doc(widget.project.projectId)
                          .collection('Comments')
                          .orderBy('UploadTime', descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData || auth.currentUser == null) {
                          return Text("NO DATA");
                        } else {
                          return ListView(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: snapshot.data.docs.map((
                              QueryDocumentSnapshot document,
                            ) {
                              var data = document.data();
                              if (data != null) {
                                print("SenderUID is ${data['SenderUid']}");
                                return CommentCard(
                                  comment: Comment(
                                    message: data['Message'],
                                    senderUid: data['SenderUid'],
                                    uploadTime: data['UploadTime'],
                                  ),
                                );
                              }
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            Material(
              elevation: 0,
              child: Container(
                height: 55,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          width: 225,
                          height: 35,
                          child: TextField(
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold,
                            ),
                            controller: messageController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 15, left: 5),
                              hintText: 'Add a public comment',
                              hintStyle: TextStyle(
                                fontFamily: 'Nexa',
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                              fillColor: Color(0xFF4b4266),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color(0xFF4f83c2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color(0xFF4f83c2),
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color(0xFF4f83c2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      FlatButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          ChatManager manager = ChatManager();
                          if (messageController.text != '') {
                            manager.uploadComment(
                              widget.project.projectId,
                              messageController.text,
                              Timestamp.now(),
                              auth.currentUser.uid,
                            );
                            messageController.clear();
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.amber,
                        child: Icon(
                          Icons.send,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
