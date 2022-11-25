import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/users.dart';

final db = FirebaseFirestore.instance;

void deleteFriend(String friendId) {
  db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .delete()
      .then(
        (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
      );
}

void sendFriendRequest(String friendId) async {
  var friendDoc = await db.collection("users").doc(friendId).get();
  if (friendDoc.data()!["friends"] != null &&
      (friendDoc.data()!["friends"] as Map)
          .keys
          .contains(FirebaseAuth.instance.currentUser!.uid)) {
    print("Already Friends");
    return;
  }
  db.collection("users").doc(friendId).update({
    "friends": {FirebaseAuth.instance.currentUser!.uid: false}
  });
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
    "sentFriendInvites": FieldValue.arrayUnion([friendId])
  }).then(
    (doc) => print("Document added"),
    onError: (e) => print("Error updating document $e"),
  );
}

List<String> getAcceptedFriends() {
  Map<dynamic, dynamic> friends = {};
  List<String> acceptedFriends = [];
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
        (doc) => friends = doc.data()!["friends"],
        onError: (e) => print("Error updating document $e"),
      );

  friends.forEach((key, value) {
    if (!value) {
      acceptedFriends.add(key);
    }
  });
  return acceptedFriends;
}

Future<List> getSentFriendRequests() async {
  List<dynamic> friendRequests = [];
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (res.data()!["sentFriendInvites"] == null) return [];
  friendRequests = (res.data()!["sentFriendInvites"]! as List<dynamic>);

  return friendRequests;
}

Future<List> getRecievedFriendRequests() async {
  Map<dynamic, dynamic> friends = {};
  List<String> requests = [];
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (res.data()!["friends"] == null) return [];
  friends = (res.data()!["friends"]! as Map<dynamic, dynamic>);
  friends.forEach((key, value) {
    if (!value) {
      requests.add(key);
    }
  });

  return requests;
}

void acceptFriendRequest(String id) async {
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
    "friends": {id: true}
  }, SetOptions(merge: true));
  db.collection("users").doc(id).set({
    "friends": {FirebaseAuth.instance.currentUser!.uid: true}
  }, SetOptions(merge: true));
}

void denyFriendRequest(String id) async {
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  Map friends = res.data()!["friends"]!;
  friends.remove(id);
  print(friends);
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update(
    {
      "friends": friends,
    },
  );
}

Future<List<KoalUser>> getFriends() async {
  List<KoalUser> friends = [];
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  if (res.data()!["friends"] == null) return [];

  for (var e in (res.data()!["friends"] as Map).entries) {
    if (e.value) {
      KoalUser? user = await getUser(e.key);
      if (user != null) {
        friends.add(user);
      }
    }
  }
  return friends;
}
