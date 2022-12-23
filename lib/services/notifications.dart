import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

final db = FirebaseFirestore.instance;

void sendPushMessage(
  String title,
  String body,
  String token,
) async {
  try {
    var res = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAOwJmGgY:APA91bEDp2XgTJdAfdiAbqBzTKe2WC169kZglHQhPcFqozXelCyoQZoXPMiT8ymrmitbASgdeeiRSh1gDOlR6rCYAZVspfGBB6aJbyW-9QsdQijqJL1HREnMUXfE2-rgu1U6422Gv4mb',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
            'sound': 'default'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          "to": token,
        },
      ),
    );
    print(res.statusCode);
  } catch (e) {
    print("error push notification");
  }
}

Future addNewNotfication(String type, String id) async {
  if (type == "friend") {
    await db.collection("users").doc(id).update({
      "FriendNotifications": FieldValue.increment(1),
    });
  } else if (type == "debt") {
    await db.collection("users").doc(id).update({
      "DebtNotifications": FieldValue.increment(1),
    });
  }
}

Future<List<int>> getNotificationsById(String id) async {
  List<int> notifications = [];
  var value = await db.collection("users").doc(id).get();
  notifications.add(value.data()!["FriendNotifications"] ?? 0);
  notifications.add(value.data()!["DebtNotifications"] ?? 0);
  return notifications;
}

Future resetNotifications(String type, String id) async {
  if (type == "friend") {
    await db.collection("users").doc(id).update({
      "FriendNotifications": 0,
    });
  } else if (type == "debt") {
    await db.collection("users").doc(id).update({
      "DebtNotifications": 0,
    });
  }
}
