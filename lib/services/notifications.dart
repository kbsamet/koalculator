import 'dart:convert';

import 'package:http/http.dart' as http;

void sendPushMessage(String title, String body, String token) async {
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
            'status': 'done'
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
