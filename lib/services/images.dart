import 'package:firebase_storage/firebase_storage.dart';

Future<String?> getImage(
  String? pic,
) async {
  if (pic != null) {
    String url =
        await FirebaseStorage.instance.refFromURL(pic!).getDownloadURL();

    return url;
  }
}
