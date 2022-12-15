import 'package:flutter/material.dart';
import 'package:koalculator/config/ad_config.dart';
import 'package:koalculator/config/firebase_config.dart';
import 'package:koalculator/config/flutter_config.dart';
import 'package:koalculator/screens/main_page.dart';
import 'package:koalculator/theme/theme_data.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;

void main() async {
  initFlutter();
  await initMobAds();
  await initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: darkTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const MainPage(),
      ),
    );
  }
}
