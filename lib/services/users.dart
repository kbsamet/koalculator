import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;
Future<KoalUser?> getUser(id) async {
  var res = await db.collection("users").doc(id).get();
  if (res.data() == null) return null;
  return KoalUser.fromJson(res.data()!);
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
