//It's better to name the class different from User because User is also available in firebase_auth.dart. Which confuses the program.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:terptune/models/users.dart';
import 'package:terptune/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Users? _userFromFirebaseUser(User? user) {
    return user != null ? Users(uid: user.uid) : null;
  }

  // auth change user stream
  //Firebase User is now User?
  //onAuthStateChanged is now authStateChanges()

  Stream<Users?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user!));
  }

  //sign in Anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await DatabaseService(uid: user!.uid).updateUserData(name, email);
      return _userFromFirebaseUser(user);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return 'The email address is already in use.';
        } else {
          print('FirebaseAuthException: ${e.message}');
          return 'An error occurred. Please try again later.';
        }
      } else {
        print('Exception: $e');
        return 'An error occurred. Please try again later.';
      }
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
