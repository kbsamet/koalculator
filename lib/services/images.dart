import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance.ref();
Future<String?> getImage(
  String? pic,
) async {
  if (pic != null) {
    String url =
        await FirebaseStorage.instance.refFromURL(pic).getDownloadURL();

    return url;
  }
  return null;
}

Future<String?> getProfilePic(String? id) async {
  try {
    String url = await storage.child("profilePics/$id").getDownloadURL();

    return url;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<String?> getGroupPic(String? id) async {
  try {
    String url = await storage.child("groupProfilePics/$id").getDownloadURL();

    return url;
  } catch (e) {
    print(e);
  }
  return null;
}
