import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/groups/add_image.dart';
import 'package:koalculator/services/groups.dart';

import '../../components/groups/group_friend_view.dart';
import '../../models/user.dart';
import '../../services/friends.dart';

final db = FirebaseFirestore.instance;

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  TextEditingController groupName = TextEditingController();
  User? loggedUser = FirebaseAuth.instance.currentUser;
  List<KoalUser> friends = [];
  List<KoalUser> addedFriends = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserFriends();
  }

  void getUserFriends() async {
    List<KoalUser> newFriends = await getFriends();
    setState(() {
      friends = newFriends;
    });
  }

  void addOrRemoveFriend(KoalUser user, bool add) {
    setState(() {
      if (add) {
        addedFriends.add(user);
      } else {
        addedFriends.remove(user);
      }
    });
  }

  void createGroup() async {
    if (addedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gruba en az 1 kişi eklemelisin")));
      return;
    }
    if (groupName.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Grup İsmi boş olamaz")));
      return;
    }

    if (await createNewGroup(groupName.text, addedFriends)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Grup başarıyla oluşturuldu")));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Bir hata oluştu")));
    }
  }

  String getAddedNames() {
    String addedNames = "";
    for (var element in addedFriends) {
      addedNames += "${element.name} ,";
    }

    return addedNames.substring(0, addedNames.length - 2);
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Grup Oluştur",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color(0xffF71B4E)),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const AddImage(),
            const SizedBox(
              height: 20,
            ),
            Container(
                padding: const EdgeInsets.all(10),
                color: const Color(0xff292A33),
                child: TextField(
                  controller: groupName,
                  decoration: const InputDecoration(
                    hintText: "Grubun İçin Bir İsim Belirle",
                    hintStyle: TextStyle(fontWeight: FontWeight.bold),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffAD0028)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffAD0028)),
                    ),
                  ),
                )),
            Container(
                height: 35,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    color: Color(0xff8A525F),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: const TextField(
                  decoration: InputDecoration(
                      isDense: true,
                      hintText: "Kişilerden ara",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold),
                      border: InputBorder.none),
                )),
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              color: const Color(0xff292A33),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Eklediğin Kişiler",
                    style: TextStyle(
                        color: Color(0xffF24E74),
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  Text(
                    addedFriends.isEmpty ? "" : getAddedNames(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                height: 200,
                child: ListView(
                    children: friends
                        .map((e) => GroupFriendView(
                              user: e,
                              addUser: addOrRemoveFriend,
                            ))
                        .toList())),
            const SizedBox(
              height: 20,
            ),
            DefaultButton(onPressed: createGroup, text: "Grup Oluştur")
          ],
        ),
      ),
    );
  }
}
