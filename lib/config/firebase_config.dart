import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

Future initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await FirebaseMessaging.instance.requestPermission();
  print(await FirebaseMessaging.instance.getToken());

  final token = await FirebaseMessaging.instance.getToken();
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);

  FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(iOS: initializationSettingsDarwin),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("dsd");
  // handle action
}

Future onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  print(title);
  print(body);
}
