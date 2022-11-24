import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

List<String> getFriendRequests() {
  Map<dynamic, dynamic> friends = {};
  List<String> friendRequests = [];
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
        (doc) => friends = doc.data()!["friends"],
        onError: (e) => print("Error updating document $e"),
      );

  friends.forEach((key, value) {
    if (value) {
      friendRequests.add(key);
    }
  });
  return friendRequests;
}
