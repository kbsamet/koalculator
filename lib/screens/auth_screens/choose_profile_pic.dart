import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/helpers/imageHelper.dart';
import 'package:koalculator/screens/dashboard.dart';
import 'package:koalculator/services/users.dart';

class ChooseProfilePicScreen extends StatefulWidget {
  const ChooseProfilePicScreen({super.key});

  @override
  State<ChooseProfilePicScreen> createState() => _ChooseProfilePicScreenState();
}

class _ChooseProfilePicScreenState extends State<ChooseProfilePicScreen> {
  CroppedFile? profilePic;
  TextEditingController bioController = TextEditingController();

  void enterBio() {
    String? result = setBio(profilePic, bioController.text);

    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Dashboard()));
  }

  void enterPic() async {
    XFile? file = await pickImageHelper();
    if (file == null) {
      return;
    }

    CroppedFile? cropped = await cropImageHelper(file);
    if (cropped == null) {
      return;
    }
    var profilePicRef = refImageHelper();

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
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Koalculator",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    color: Color(0xffF71B4E),
                    indent: 30,
                    endIndent: 30,
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Profil fotoğrafı seç",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Container(
                    margin: const EdgeInsets.all(30),
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                        color: Color(0xff292A33), shape: BoxShape.circle),
                    child: Stack(
                      children: [
                        profilePic == null
                            ? Container()
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
                            onTap: enterPic,
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
                  const Text(
                    "Bir Bio gir",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DefaultTextInput(
                    controller: bioController,
                    icon: Icons.abc,
                    noIcon: true,
                    height: 100,
                    maxLines: 5,
                    hintText: "Bio",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child:
                          DefaultButton(onPressed: enterBio, text: "Devam et"))
                ]),
          ),
        ),
      ),
    );
  }
}
