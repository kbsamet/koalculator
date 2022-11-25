import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/main_page.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

final db = FirebaseFirestore.instance;

class ChooseNameScreen extends StatefulWidget {
  const ChooseNameScreen({Key? key}) : super(key: key);

  @override
  State<ChooseNameScreen> createState() => _ChooseNameScreenState();
}

class _ChooseNameScreenState extends State<ChooseNameScreen> {
  TextEditingController nicknameController = TextEditingController();

  void SetName() async {
    var data = await db.collection("users").get();
    for (var user in data.docs) {
      if (user.data()["name"] == nicknameController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("İsim Daha önce alınmış.")));
        return;
      }
    }

    db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"name": nicknameController.text});
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()));
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
                  DefaultButton(onPressed: SetName, text: "Devam et"),
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
