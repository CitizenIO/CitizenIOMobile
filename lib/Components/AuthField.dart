import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  AuthField({
    @required this.controller,
    @required this.isPassword,
    @required this.placeholder,
  });

  final TextEditingController controller;
  final bool isPassword;
  final String placeholder;

  @override
  _AuthFieldState createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: SizedBox(
        width: 325,
        height: 40,
        child: TextField(
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nexa',
          ),
          controller: widget.controller,
          obscureText: widget.isPassword,
          cursorColor: Color(0xFF50fa7b),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 10),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              fontFamily: 'Nexa',
              color: Colors.grey,
            ),
            fillColor: Color(0xFF4b4266),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2.0,
                color: Color(0xFFef63f6),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2.0,
                color: Color(0xFFef63f6),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                width: 2.0,
                color: Color(0xFFef63f6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
