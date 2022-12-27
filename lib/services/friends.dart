import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/notifications.dart';
import 'package:koalculator/services/users.dart';

final db = FirebaseFirestore.instance;

enum FriendStatus { accepted, pending, notFriends, sent }

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

Future sendFriendRequest(String friendId, dynamic context) async {
  var friendDoc = await db.collection("users").doc(friendId).get();
  if (friendDoc.data()!["friends"] != null &&
      (friendDoc.data()!["friends"] as Map)
          .keys
          .contains(FirebaseAuth.instance.currentUser!.uid)) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bu kullanıcıyla zaten arkadaşsınız")));
    return;
  }
  db.collection("users").doc(friendId).set({
    "friends": {FirebaseAuth.instance.currentUser!.uid: false}
  }, SetOptions(merge: true));
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
    "sentFriendInvites": FieldValue.arrayUnion([friendId])
  }).then(
    (doc) => ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("İstek Gönderildi"))),
    onError: (e) => print("Error updating document $e"),
  );

  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then(
        (doc) => sendPushMessage(
            "Arkadaş İsteği",
            "${doc.data()!["name"]} size bir arkadaş isteği gönderdi",
            friendDoc.data()!["token"]),
        onError: (e) => print("Error updating document $e"),
      );
}

Future sendFriendRequestByName(String friendName, dynamic context) async {
  var friendDoc = await db.collection("users").get();
  for (var element in friendDoc.docs) {
    if (element.data()["name"] == friendName &&
        element.id != FirebaseAuth.instance.currentUser!.uid) {
      sendFriendRequest(element.id, context);
      //send a push notification

      KoalUser? thisUser =
          await getUser(FirebaseAuth.instance.currentUser!.uid);
      KoalUser? friend = await getUser(element.id);
      sendPushMessage("Arkadaş İsteği",
          "${thisUser!.name} size bir arkadaş isteği gönderdi", friend!.token!);

      return;
    }
  }

  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Bu isimde biri bulunamadı")));
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

Future acceptFriendRequest(String id) async {
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
    "friends": {id: true}
  }, SetOptions(merge: true));
  db.collection("users").doc(id).set({
    "friends": {FirebaseAuth.instance.currentUser!.uid: true},
    "sentFriendInvites":
        FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
  }, SetOptions(merge: true));

  KoalUser? thisUser = await getUser(FirebaseAuth.instance.currentUser!.uid);
  getUser(id).then((value) {
    sendPushMessage("Arkadaşlık Onayı",
        "${thisUser!.name} arkadaşlık isteğinizi kabul etti", value!.token!);
  });
}

Future denyFriendRequest(String id) async {
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  Map friends =
      res.data()!["friends"]! == null ? {} : res.data()!["friends"]! as Map;
  friends.remove(id);

  var friend = await db.collection("users").doc(id).get();

  List sentInvites = friend.data()!["sentFriendInvites"] == null
      ? []
      : friend.data()!["sentFriendInvites"] as List;
  sentInvites.remove(FirebaseAuth.instance.currentUser!.uid);

  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update(
    {
      "friends": friends,
    },
  );
  db.collection("users").doc(id).update(
    {
      "sentFriendInvites": sentInvites,
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
        user.id = e.key;
        friends.add(user);
      }
    }
  }
  return friends;
}

Future<KoalUser> getFriend(String friendId) async {
  KoalUser? friend = await getUser(friendId);

  return friend!;
}

Future<FriendStatus> getFriendStatus(String id) async {
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  if (res.data()!["friends"] == null) return FriendStatus.notFriends;
  if ((res.data()!["friends"] as Map).containsKey(id)) {
    return res.data()!["friends"][id]
        ? FriendStatus.accepted
        : FriendStatus.pending;
  }
  if ((res.data()!["sentFriendInvites"] as List).contains(id)) {
    return FriendStatus.sent;
  }
  return FriendStatus.notFriends;
}

Future removeFriend(String id) async {
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
  var friendRes = await db.collection("users").doc(id).get();
  Map newFriends = res.data()!["friends"]!;
  newFriends.remove(FirebaseAuth.instance.currentUser!.uid);
  db.collection("users").doc(id).update(
    {
      "friends": newFriends,
    },
  );
}

Future cancelFriendRequest(String id) async {
  var res = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  List sentFriendInvites = res.data()!["sentFriendInvites"]!;
  sentFriendInvites.remove(id);
  print(sentFriendInvites);
  db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update(
    {
      "sentFriendInvites": sentFriendInvites,
    },
  );
  var friendRes = await db.collection("users").doc(id).get();
  Map newFriends = friendRes.data()!["friends"]!;
  newFriends.remove(FirebaseAuth.instance.currentUser!.uid);
  db.collection("users").doc(id).update(
    {
      "friends": newFriends,
    },
  );
}
