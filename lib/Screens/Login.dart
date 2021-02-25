import 'package:CitizenIO/Database/AuthManager.dart';
import 'package:CitizenIO/Screens/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import '../Components/AuthField.dart';
import './Register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool getCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser == null;
  }

  signOut() {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.signOut();
  }

  @override
  void initState() {
    super.initState();
    // signOut();
    if (!getCurrentUser()) {
      Future.delayed(
        Duration.zero,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf6f5fb),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CitizenIO",
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
                        builder: (context) => Register(),
                      ),
                    );
                  },
                  child: Text(
                    'Register Here',
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
                          'Login',
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
                      print("Login pressed");
                      AuthManager authManager = AuthManager();
                      await authManager.login(
                          emailController.text, passwordController.text);
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
