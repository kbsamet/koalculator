import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/friends/friend_in_contact.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  Map<Contact, KoalUser?> friendsInContact = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts();
  }

  void getContacts() async {
    Map<String?, KoalUser> userPhones = {};
    var users = await db.collection("users").get();
    for (var element in users.docs) {
      String? phone = element.data()["phoneNumber"];
      KoalUser user = KoalUser.fromJson(element.data());
      userPhones.addAll({phone: user});
    }

    print(userPhones);
    List<Contact> contacts = await ContactsService.getContacts();
    for (var element in contacts) {
      String phone =
          element.phones![0].value.toString().replaceAll(RegExp(r"\s+"), "");
      phone = phone.replaceAll('(', '').replaceAll(')', '');

      print(phone);
      List match =
          userPhones.keys.where((e) => e != null && phone.contains(e)).toList();
      if (match.isNotEmpty) {
        setState(() {
          friendsInContact.addAll({element: userPhones[match.first]});
        });
      }
    }

    print(friendsInContact);
  }

  final tabBar = const TabBar(
      indicatorColor: Color(0xffF71B4E),
      labelColor: Color(0xffFF6D8F),
      unselectedLabelColor: Color(0xffAFAFAF),
      labelStyle: TextStyle(
          fontWeight: FontWeight.bold, fontFamily: "QuickSand", fontSize: 16),
      tabs: [
        Tab(
          text: "Öneriler",
        ),
        Tab(
          text: "Arkadaşlar",
        ),
        Tab(
          text: "İstekler",
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff303139),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
              appBar: AppBar(
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 25,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: const Text(
                    "Koalculator",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xff303139),
                  bottom: PreferredSize(
                    preferredSize: tabBar.preferredSize,
                    child: Material(
                      color: const Color(0xff303139),
                      child: tabBar,
                    ),
                  )),
              body: TabBarView(children: [
                Container(
                  child: Column(
                    children: friendsInContact.entries
                        .map((e) =>
                            FriendInContact(user: e.value!, contact: e.key))
                        .toList(),
                  ),
                ),
                Container(),
                Container(),
              ])),
        ));
  }
}
