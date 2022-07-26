import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:waddiny/models/user.dart';

class Auth extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CustomUser currentUser;

  bool get isAuth{
    return _auth.currentUser!=null;
  }

  Future<void> signInWithEmail({String email, String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> addUser(
      String id, String fullName, String email, String phone) async {
    DocumentReference user =
        FirebaseFirestore.instance.collection('users').doc(id);
    user.set({'email': email, 'name': fullName, 'phone': phone});
  }

  Future<User> getUserInfo() async {
    CustomUser currentUserData;
    try {
      String userId = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      currentUserData = CustomUser.fromJson(user.data());
      currentUser = currentUserData;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
