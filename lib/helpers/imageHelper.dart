import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final storage = FirebaseStorage.instance.ref();

Future<CroppedFile?> cropImageHelper(XFile? file) async {
  CroppedFile? cropped = await ImageCropper().cropImage(
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    maxHeight: 150,
    maxWidth: 150,
    sourcePath: file!.path,
  );
  return cropped;
}

Future<XFile?> pickImageHelper() async {
  return ImagePicker().pickImage(source: ImageSource.gallery);
}

Reference refImageHelper() {
  return storage.child("profilePics/${FirebaseAuth.instance.currentUser!.uid}");
}
