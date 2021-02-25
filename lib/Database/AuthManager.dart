import 'package:firebase_auth/firebase_auth.dart';
import './DbManager.dart';

class AuthManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseManager manager = DatabaseManager();

  login(String email, String password) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Error => $e");
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  register(String username, String email, String password, String phoneNumber) {
    Future.delayed(Duration.zero, () async {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential cred) async {
        print("Successfully registered user");
        await manager.saveUserData(username, email, phoneNumber);
        print("Success!");
      }).catchError((err) {
        print("Error is ${err.message}");
        print("Type is ${err.message.runtimeType}");
      });
      print("Regisering user...");
    });
  }
}
