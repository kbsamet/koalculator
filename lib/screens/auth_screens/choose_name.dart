import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/choose_profile_pic.dart';
import 'package:koalculator/services/users.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

class ChooseNameScreen extends StatefulWidget {
  const ChooseNameScreen({Key? key}) : super(key: key);

  @override
  State<ChooseNameScreen> createState() => _ChooseNameScreenState();
}

class _ChooseNameScreenState extends State<ChooseNameScreen> {
  TextEditingController nicknameController = TextEditingController();

  void enterNickname() async {
    if (nicknameController.text.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İsim 12 karakterden kısa olmalı.")));
      return;
    }
    if (nicknameController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İsim 3 karakterden uzun olmalı.")));
      return;
    }
    bool isSetted = await setName(nicknameController.text);

    if (!isSetted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İsim Daha önce alınmış.")));
      return;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ChooseProfilePicScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1B1C26),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
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
                    height: 30,
                  ),
                  DefaultTextInput(
                    controller: nicknameController,
                    icon: Icons.person,
                    hintText: "Kullanıcı Adı",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultButton(onPressed: enterNickname, text: "Devam et"),
                  const SizedBox(
                    height: 30,
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
