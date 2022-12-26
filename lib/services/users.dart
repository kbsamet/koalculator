import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/debts.dart';

import '../screens/auth_screens/login_page.dart';

final db = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance.ref();

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
  db.collection("users").doc(id).update({"bio": bio});
  setName(name);
  return true;
}

Future<bool> setName(String nickname) async {
  var data = await db.collection("users").get();
  for (var user in data.docs) {
    if (user.data()["name"] == nickname) {
      return false;
    }
  }

  //update all the userNames in users groups
  var groups = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (groups.data()!["groups"] != null) {
    for (var group in groups.data()!["groups"]) {
      print(groups.data()!["name"]);
      var groupData = await db.collection("groups").doc(group).get();
      var userNames = groupData.data()!["userNames"] as List;
      userNames[userNames.indexOf(groups.data()!["name"])] = nickname;
      db.collection("groups").doc(group).update({"userNames": userNames});
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

Future deleteAccount(context) async {
  //delete all the groups
  var groups = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  if (groups.data() != null && groups.data()!["groups"] != null) {
    for (var group in groups.data()!["groups"]) {
      print(group);
      var groupData = await db.collection("groups").doc(group).get();
      var userNames = groupData.data()!["userNames"] as List;

      userNames.remove(groups.data()!["name"]);
      var users = groupData.data()!["users"] as List;
      users.remove(FirebaseAuth.instance.currentUser!.uid);
      db
          .collection("groups")
          .doc(group)
          .update({"users": users, "userNames": userNames});
    }
  }

  //delete all the friends
  var friends = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (friends.data() != null && friends.data()!["friends"] != null) {
    for (var friend in (friends.data()!["friends"] as Map).keys) {
      var friendData = await db.collection("users").doc(friend).get();
      var friends = friendData.data()!["friends"] as Map;
      friends.remove(FirebaseAuth.instance.currentUser!.uid);
      db.collection("users").doc(friend).update({"friends": friends});
    }
  }

  //delete all the friend requests
  var allUsers = await db.collection("users").get();
  for (var user in allUsers.docs) {
    List? friendRequests = user.data()["friendRequests"] as List?;

    if (friendRequests != null &&
        friendRequests.contains(FirebaseAuth.instance.currentUser!.uid)) {
      friendRequests.remove(FirebaseAuth.instance.currentUser!.uid);
      db
          .collection("users")
          .doc(user.id)
          .update({"friendRequests": friendRequests});
    }

    Map? debts = user.data()["debts"] as Map?;
    if (debts != null &&
        debts.keys.contains(FirebaseAuth.instance.currentUser!.uid)) {
      debts.remove(FirebaseAuth.instance.currentUser!.uid);
      db.collection("users").doc(user.id).update({"debts": debts});
    }

    Map? pastDebts = user.data()["pastDebts"] as Map?;
    if (pastDebts != null &&
        pastDebts.keys.contains(FirebaseAuth.instance.currentUser!.uid)) {
      pastDebts.remove(FirebaseAuth.instance.currentUser!.uid);
      db.collection("users").doc(user.id).update({"pastDebts": pastDebts});
    }
  }

  //delete all the debts
  Map debts = await getDebtsIds();
  for (var debts in debts.values) {
    for (var debt in debts) {
      db.collection("debts").doc(debt).delete();
    }
  }

  //delete all the past debts
  Map pastDebts = await getPastDebtsIds();
  for (var pastDebts in pastDebts.values) {
    for (var pastDebt in pastDebts) {
      db.collection("pastDebts").doc(pastDebt).delete();
    }
  }

  //delete the user
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).delete();

  //delete profile pic from storage
  storage
      .child("profilePics/${FirebaseAuth.instance.currentUser!.uid}")
      .delete();

  try {
    //delete the user from auth
    await FirebaseAuth.instance.currentUser!.delete();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content:
          Text("Hesabınızın silinmesi için tekrar giriş yapmanız gerekiyor"),
    ));
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen(delete: true)));
  }
}
