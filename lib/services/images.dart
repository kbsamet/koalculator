import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance.ref();
Future<String?> getImage(
  String? pic,
) async {
  if (pic != null) {
    String url =
        await FirebaseStorage.instance.refFromURL(pic!).getDownloadURL();

    return url;
  }
}

Future<String?> getProfilePic(String? id) async {
  try {
    String url = await storage.child("profilePics/${id}").getDownloadURL();

    return url;
  } catch (e) {
    print(e);
  }
}
