import 'package:flutter/material.dart';

class ProjectField extends StatefulWidget {
  ProjectField({
    @required this.controller,
    @required this.placeholder,
  });

  final TextEditingController controller;
  final String placeholder;

  @override
  _ProjectFieldState createState() => _ProjectFieldState();
}

class _ProjectFieldState extends State<ProjectField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: 325,
        height: 40,
        child: TextField(
          autocorrect: false,
          // textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nexa',
            fontWeight: FontWeight.bold,
          ),
          controller: widget.controller,
          cursorColor: Color(0xFF50fa7b),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(
              top: 15,
              left: 10,
              right: 10,
            ),
            hintText: widget.placeholder,
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
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blue,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2.0,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
