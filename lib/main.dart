import 'package:flutter/material.dart';
import 'Screens/Login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CitizenIO());
}

class CitizenIO extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CitizenIO',
      home: Login(),
    );
  }
}
