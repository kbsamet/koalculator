import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

final db = FirebaseFirestore.instance;

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController friendName = TextEditingController();
  User? loggedUser = FirebaseAuth.instance.currentUser;

  void AddFriend() async {
    var data = await db.collection("users").get();
    for (var user in data.docs) {
      if (user.data()["name"] == friendName.text) {
        db.collection("users").doc(loggedUser!.uid).update({
          "sentFriendRequests": FieldValue.arrayUnion([user.id])
        });
        db.collection("users").doc(user.id).update({
          "pendingFriendRequests": FieldValue.arrayUnion([loggedUser!.uid])
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${friendName.text} isimli kullanıcı bulunamadı.")));
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
                    controller: friendName,
                    icon: Icons.person,
                    hintText: "Kullanıcı Adı",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultButton(onPressed: AddFriend, text: "Devam et"),
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
