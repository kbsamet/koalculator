import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;

Future<UserCredential> createUser(String email, String password) async {
  return FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
}

Future<KoalUser?> getUser(id) async {
  var res = await db.collection("users").doc(id).get();
  if (res.data() == null) return null;
  KoalUser user = KoalUser.fromJson(res.data()!);
  user.id = id;
  return user;
}

Future<List<KoalUser>?> getUsers(List<dynamic> users) async {
  List<KoalUser> newUsers = [];
  for (var element in users) {
    var res = await db.collection("users").doc(element).get();

    newUsers.add(KoalUser.fromJson(res.data()!));
  }
  return newUsers;
}

Future<bool> updateUser(
    String id, String name, String bio, bool sameName, context) async {
  if (!sameName) {
    var data = await db.collection("users").get();
    for (var user in data.docs) {
      if (user.data()["name"] == name) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("İsim Daha önce alınmış.")));
        return false;
      }
    }
  }
  db.collection("users").doc(id).update({"name": name, "bio": bio});
  return true;
}

Future<bool> setName(String nickname) async {
  var data = await db.collection("users").get();
  for (var user in data.docs) {
    if (user.data()["name"] == nickname) {
      return false;
    }
  }

  db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update({"name": nickname});

  return true;
}

String? setBio(CroppedFile? profilePic, String bio) {
  if (profilePic == null) {
    return "Lütfen bir profil fotoğrafı seçin";
  }
  if (bio.isEmpty) {
    return "Lütfen bir bio yazın";
  }
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
    "bio": bio,
  }, SetOptions(merge: true));
  return null;
}

void setPhoneNumber(String phoneNumber) {
  db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .set({"phoneNumber": phoneNumber}, SetOptions(merge: true));
}

PhoneAuthCredential verifyAccount(String verificationId, String smsCode) {
  return PhoneAuthProvider.credential(
      verificationId: verificationId, smsCode: smsCode);
}

Future<DocumentSnapshot<Map<String, dynamic>>> getAllUsersById() async {
  return db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUsersWithElement(
    dynamic element) async {
  return db.collection("users").doc(element).get();
}

Future<QuerySnapshot<Map<String, dynamic>>> getAllUsers() async {
  return db.collection("users").get();
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUserByFriendId(
    String? Id) async {
  return db.collection("users").doc(Id).get();
}
