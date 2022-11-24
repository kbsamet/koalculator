import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/components/dashboard/group_list_view.dart';
import 'package:koalculator/models/debt.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;

void deleteFriend(String id) {
  db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .delete()
      .then(
        (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
      );
}

void addFriend(Map<String, bool> friend) {
  db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .set(friend)
      .then(
        (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
      );
}

void getAcceptedFriends() {
  Map<dynamic, dynamic> friends = {};
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
        (doc) => friends = doc.data()!["friends"],
        onError: (e) => print("Error updating document $e"),
      );
}
