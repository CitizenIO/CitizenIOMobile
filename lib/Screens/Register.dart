import 'dart:io';

import 'package:CitizenIO/Components/AuthField.dart';
import 'package:CitizenIO/Database/AuthManager.dart';
import 'package:CitizenIO/Screens/Home.dart';
import 'package:CitizenIO/Screens/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  final picker = ImagePicker();
  File _profilePic;
  Widget image = CircleAvatar(
    backgroundImage: AssetImage('assets/images/avatar.jpg'),
    radius: 80,
    backgroundColor: Colors.white,
  );

  Future<File> getProfilePic() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // setState(() {
      _profilePic = File(pickedFile.path);
      // });
      if (_profilePic != null) {
        print("ProfilePic => $_profilePic");
        return _profilePic;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Nexa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () async {
                    print("Get profile pic");
                    File profilePic = await getProfilePic();
                    setState(() {
                      image = CircleAvatar(
                        backgroundImage: FileImage(profilePic),
                        radius: 80,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: image,
                  ),
                ),
                AuthField(
                  controller: usernameController,
                  isPassword: false,
                  placeholder: 'Full Name',
                ),
                AuthField(
                  controller: phoneNumberController,
                  isPassword: false,
                  placeholder: 'Phone Number',
                ),
                AuthField(
                  controller: emailController,
                  isPassword: false,
                  placeholder: 'Email',
                ),
                AuthField(
                  controller: passwordController,
                  isPassword: true,
                  placeholder: 'Password',
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  },
                  child: Text(
                    'Login Here',
                    style: TextStyle(
                      color: Color(0xFF8bbaf5),
                      fontFamily: 'Nexa',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
                          'Register',
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
                      AuthManager authManager = AuthManager();
                      await authManager.register(
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                        phoneNumberController.text,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
