import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koalculator/models/user.dart';

import '../../services/users.dart';
import '../dashboard.dart';

final storage = FirebaseStorage.instance.ref();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CroppedFile? profilePic;
  String? imageUrl;
  KoalUser? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePic();
    getCurrentUser();
  }

  getCurrentUser() async {
    KoalUser user_ = (await getUser(FirebaseAuth.instance.currentUser!.uid))!;
    setState(() {
      user = user_;
    });
  }

  void getProfilePic() async {
    try {
      String url = await storage
          .child("profilePics/${FirebaseAuth.instance.currentUser!.uid}")
          .getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {}
  }

  void setProfilePic() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }

    CroppedFile? cropped = await ImageCropper().cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 150,
      maxWidth: 150,
      sourcePath: file.path,
    );
    if (cropped == null) {
      return;
    }
    var profilePicRef =
        storage.child("profilePics/${FirebaseAuth.instance.currentUser!.uid}");

    try {
      await profilePicRef.putFile(File(cropped.path));
    } catch (e) {
      print(e);
    }
    setState(() {
      profilePic = cropped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff1B1C26),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff1B1C26),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    size: 30, color: Color(0xffF71B4E)),
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                )),
              ),
              title: const Text(
                "Profil",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color(0xffF71B4E)),
              ),
            ),
            body: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        height: 150,
                        width: 150,
                        decoration: const BoxDecoration(
                            color: Color(0xff292A33), shape: BoxShape.circle),
                        child: Stack(
                          children: [
                            profilePic == null
                                ? (imageUrl == null
                                    ? Container()
                                    : ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100)),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl!,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(
                                            color: Color(0xffF71B4E),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.fill,
                                        )))
                                : ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    child: Image.file(
                                      File(profilePic!.path),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.fill,
                                    )),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: setProfilePic,
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Color(0xffF71B4E),
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Text(
                          user == null ? "" : user!.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Color.fromARGB(255, 255, 202, 214)),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(right: 50, left: 50, top: 40),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // aşağıdaki 3 containeri tek hale nasıl getirebilirim ?? deliricem...
                              Container(
                                child: const Text(
                                  "Gruplar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color:
                                          Color.fromARGB(255, 255, 245, 247)),
                                ),
                              ),
                              const SizedBox(
                                  height: 160,
                                  child: VerticalDivider(color: Colors.red)),
                              Container(
                                child: const Text(
                                  "Arkadaşlar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color:
                                          Color.fromARGB(255, 255, 239, 242)),
                                ),
                              ),
                            ]),
                      )
                    ]))));
  }
}
