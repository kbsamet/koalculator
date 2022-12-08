import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

void initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
