import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/components/empty_button.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/screens/main_page.dart';
import 'package:koalculator/services/friends.dart';

import '../../services/users.dart';

final storage = FirebaseStorage.instance.ref();

class ProfileScreen extends StatefulWidget {
  final KoalUser? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CroppedFile? profilePic;
  String? imageUrl;
  KoalUser? user;
  bool otherUser = false;
  FriendStatus? friendStatus;

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.user == null) {
      getCurrentUser();
    } else {
      setState(() {
        user = widget.user;
        otherUser = true;
      });
      checkFriends();
    }
    getProfilePic();
  }

  checkFriends() async {
    friendStatus = await getFriendStatus(user!.id!);
    setState(() {});
  }

  getCurrentUser() async {
    KoalUser user_ = (await getUser(FirebaseAuth.instance.currentUser!.uid))!;
    setState(() {
      user = user_;
      nameController.text = user!.name;
      bioController.text = user!.bio;
    });
  }

  void getProfilePic() async {
    try {
      String? id =
          otherUser ? user!.id : FirebaseAuth.instance.currentUser!.uid;
      String url = await storage.child("profilePics/$id").getDownloadURL();
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
                  onPressed: () => Navigator.of(context).pop()),
              title: const Text(
                "Profil",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color(0xffF71B4E)),
              ),
            ),
            body: Container(
                margin: const EdgeInsets.all(10),
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
                            otherUser
                                ? Container()
                                : Align(
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
                      otherUser
                          ? Text(
                              user == null ? "" : user!.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Color.fromARGB(255, 255, 202, 214)),
                            )
                          : DefaultTextInput(
                              controller: nameController,
                              icon: Icons.person,
                              noIcon: true,
                              hintText: user == null ? "" : user!.name,
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      DefaultTextInput(
                        controller: otherUser
                            ? TextEditingController(
                                text: user == null ? "" : user!.bio)
                            : bioController,
                        readOnly: otherUser,
                        hintText: user == null ? "" : user!.bio,
                        icon: Icons.abc,
                        noIcon: true,
                        maxLines: 5,
                        height: 100,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      !otherUser
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: DefaultButton(
                                      text: "Değişiklikleri Kaydet",
                                      onPressed: () async {
                                        bool res = await updateUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            nameController.text,
                                            bioController.text,
                                            nameController.text == user!.name,
                                            context);
                                        if (res) {
                                          Navigator.of(context).pop();
                                        }
                                      }),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: EmptyButton(
                                      text: "Çık",
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MainPage()));
                                      }),
                                ),
                              ],
                            )
                          : friendStatus == null
                              ? Container()
                              : friendStatus == FriendStatus.accepted
                                  ? EmptyButton(
                                      text: "Arkadaşlıktan Çıkar",
                                      onPressed: () {
                                        removeFriend(user!.id!);
                                        friendStatus = FriendStatus.notFriends;
                                        setState(() {});
                                      })
                                  : friendStatus == FriendStatus.pending
                                      ? DefaultButton(
                                          text: "Arkadaşlık İsteğini Kabul Et",
                                          onPressed: () {
                                            acceptFriendRequest(user!.id!);
                                            friendStatus =
                                                FriendStatus.notFriends;
                                            setState(() {});
                                          })
                                      : friendStatus == FriendStatus.sent
                                          ? EmptyButton(
                                              text:
                                                  "Arkadaşlık İsteğini İptal Et",
                                              onPressed: () {
                                                cancelFriendRequest(user!.id!);
                                                friendStatus =
                                                    FriendStatus.notFriends;
                                                setState(() {});
                                              })
                                          : DefaultButton(
                                              text: "Arkadaşlık İsteği Gönder",
                                              onPressed: () {
                                                sendFriendRequest(
                                                    user!.id!, context);
                                                friendStatus =
                                                    FriendStatus.sent;
                                                setState(() {});
                                              })
                    ]))));
  }
}
