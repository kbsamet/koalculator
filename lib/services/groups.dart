import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/group.dart';
import '../models/user.dart';

final db = FirebaseFirestore.instance;

Future<String> createNewGroup(
  String name,
  List<KoalUser> users,
) async {
  try {
    var value = await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var res = await db.collection("groups").add({
      "name": name,
      "userNames": users.map((e) => e.name).toList() + [value.data()!["name"]],
      "users": users.map((e) => e.id).toList() +
          [FirebaseAuth.instance.currentUser!.uid]
    });

    db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "groups": FieldValue.arrayUnion([res.id])
    });

    for (var element in users) {
      db.collection("users").doc(element.id).update({
        "groups": FieldValue.arrayUnion([res.id])
      });
    }
    return res.id;
  } catch (e) {
    print(e);
    return "";
  }
}

Future<List<Group>> getGroups() async {
  List<Group> groups = [];
  List<dynamic> groupIds = [];

  var value = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  groupIds = value.data()!["groups"];

  for (var element in groupIds) {
    Group group = await getGroupDetails(element.toString());
    group.id = element;
    groups.add(group);
  }
  return groups;
}

Future<Group> getGroupDetails(String id) async {
  var value = await db.collection("groups").doc(id).get();
  return Group.fromJson(value.data()!);
}

Future addToGroup(String groupId, KoalUser user) async {
  db.collection("groups").doc(groupId).update({
    "users": FieldValue.arrayUnion([user.id!])
  });
  db.collection("users").doc(user.id).update({
    "groups": FieldValue.arrayUnion([groupId])
  });
}

Future leaveGroup(String groupId) async {
  db.collection("groups").doc(groupId).update({
    "users": FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
  });
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
    "groups": FieldValue.arrayRemove([groupId])
  });
}
