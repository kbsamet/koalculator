import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/components/groups/group_friend_edit_view.dart';

import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/users.dart';
import '../main_page.dart';

final db = FirebaseFirestore.instance;

class EditGroupScreen extends StatefulWidget {
  final Group group;
  const EditGroupScreen({super.key, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  CroppedFile? profilePic;
  String? imageUrl;
  List<KoalUser> users = [];

  TextEditingController newName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupUsers();
    getProfilePic();
  }

  void getProfilePic() async {
    try {
      String url = await storage
          .child("groupProfilePics/${widget.group.id}")
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
    var profilePicRef = storage.child("groupProfilePics/${widget.group.id}");

    try {
      await profilePicRef.putFile(File(cropped.path));
    } catch (e) {
      print(e);
    }
    setState(() {
      profilePic = cropped;
    });
  }

  void getGroupUsers() async {
    List<KoalUser> newUsers = [];
    for (var element in widget.group.users) {
      KoalUser user = (await getUser(element))!;
      user.id = element;
      newUsers.add(user);
    }
    setState(() {
      users = newUsers;
    });
  }

  void removeFromGroup(user) {
    List<String> newUsers = [];
    for (var element in widget.group.users) {
      if (element != user.id) {
        newUsers.add(element);
      }
    }
    db.collection("groups").doc(widget.group.id).update({
      "users": newUsers,
    });
    db.collection("users").doc(user.id).update({
      "groups": FieldValue.arrayRemove([widget.group.id]),
    });
  }

  void changeGroupName() {
    if (newName.text != "") {
      db.collection("groups").doc(widget.group.id).update({
        "name": newName.text,
      });
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) => const MainPage())),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1B1C26),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff1B1C26),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 30, color: Color(0xffF71B4E)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              "Grubu Düzenle",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color(0xffF71B4E)),
            ),
          ),
          backgroundColor: const Color(0xff1B1C26),
          body: ListView(
            children: [
              Column(
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
                            onTap: () => setProfilePic(),
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
                ],
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: const Text(
                    "Grubun İsmini Değiştir",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              DefaultTextInput(
                controller: newName,
                hintText: widget.group.name,
                icon: Icons.abc,
                noIcon: true,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Color(0xffF71B4E),
                indent: 10,
                endIndent: 10,
                thickness: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: const Text(
                  "Grup Üyeleri",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: 250,
                  child: ListView(
                      children: users
                          .map((e) => Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GroupFriendEditView(
                                    user: e,
                                    removeFromGroup: removeFromGroup,
                                  ),
                                ],
                              ))
                          .toList())),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.all(10),
                  child:
                      DefaultButton(onPressed: changeGroupName, text: "Onayla"))
            ],
          ),
        ),
      ),
    );
  }
}
