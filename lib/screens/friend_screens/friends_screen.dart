import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/friends/friend_in_contact.dart';
import 'package:koalculator/components/friends/friend_invite_recieved.dart';
import 'package:koalculator/components/utils/keep_alive.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/friends.dart';
import 'package:koalculator/services/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/friends/added_friend.dart';

class FriendsScreen extends StatefulWidget {
  final int notifications;
  final VoidCallback onNotificationChange;
  const FriendsScreen({
    Key? key,
    required this.notifications,
    required this.onNotificationChange,
  }) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  Map<Contact, KoalUser?> friendsInContact = {};
  List<KoalUser> sentRequests = [];
  List<KoalUser> recievedRequests = [];
  List<KoalUser> friends = [];

  bool isContactsLoading = false;
  bool isFriendsLoading = false;
  bool isInvitationsLoading = false;

  bool resetNotifications = false;

  TextEditingController nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getContacts();
    getSentFriends();
    getRecievedRequests();
    getUserFriends();
  }

  void getUserFriends() async {
    setState(() {
      isFriendsLoading = true;
    });
    List<KoalUser> userFriends = await getFriends();
    setState(() {
      friends = userFriends;
      isFriendsLoading = false;
    });
  }

  void getRecievedRequests() async {
    setState(() {
      isInvitationsLoading = true;
    });
    List<dynamic> requestIds = await getRecievedFriendRequests();
    for (var element in requestIds) {
      var res = await getUsersWithElement(element);
      setState(() {
        KoalUser user = KoalUser.fromJson(res.data()!);
        user.id = element;
        recievedRequests.add(user);
      });
    }
    setState(() {
      isInvitationsLoading = false;
    });
  }

  void getSentFriends() async {
    List<dynamic> requestIds = await getSentFriendRequests();

    for (var element in requestIds) {
      var res = await getUsersWithElement(element);
      setState(() {
        KoalUser user = KoalUser.fromJson(res.data()!);
        user.id = element;
        sentRequests.add(user);
      });
    }
  }

  void getContacts() async {
    setState(() {
      isContactsLoading = true;
    });
    Map<String?, KoalUser> userPhones = {};
    var users = await getAllUsers();
    for (var element in users.docs) {
      String? phone = element.data()["phoneNumber"];
      KoalUser user = KoalUser.fromJson(element.data());
      user.id = element.id;

      var res = await getAllUsersById();
      if (user.id != FirebaseAuth.instance.currentUser!.uid &&
          (res.data()!["sentFriendInvites"] == null ||
              !(res.data()!["sentFriendInvites"]! as List).contains(user.id)) &&
          (res.data()!["friends"] == null ||
              !(res.data()!["friends"]! as Map).keys.contains(user.id))) {
        userPhones.addAll({phone: user});
      }
    }
    List<Contact> contacts = await ContactsService.getContacts();
    for (var element in contacts) {
      String phone =
          element.phones![0].value.toString().replaceAll(RegExp(r"\s+"), "");
      phone = phone.replaceAll('(', '').replaceAll(')', '');

      List match =
          userPhones.keys.where((e) => e != null && phone.contains(e)).toList();

      if (match.isNotEmpty) {
        setState(() {
          friendsInContact.addAll({element: userPhones[match.first]});
        });
      }
    }
    setState(() {
      isContactsLoading = false;
    });
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
                      child: TabBar(
                          onTap: (value) async {
                            if (value == 2) {
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setInt("friendNotifications", 0);
                              setState(() {
                                resetNotifications = true;
                              });

                              widget.onNotificationChange();
                            }
                          },
                          indicatorColor: const Color(0xffF71B4E),
                          labelColor: const Color(0xffFF6D8F),
                          unselectedLabelColor: const Color(0xffAFAFAF),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "QuickSand",
                              fontSize: 16),
                          tabs: [
                            const Tab(
                              text: "Öneriler",
                            ),
                            const Tab(
                              text: "Arkadaşlar",
                            ),
                            Tab(
                              child: SizedBox(
                                width: 70,
                                height: 80,
                                child: Stack(
                                  children: [
                                    const Positioned(
                                        bottom: 11, child: Text("İstekler")),
                                    widget.notifications > 0 &&
                                            !resetNotifications
                                        ? Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xffF71B4E)),
                                              child: Center(
                                                child: Text(
                                                  widget.notifications
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            )
                          ]),
                    ),
                  )),
              body: TabBarView(children: [
                KeepPageAlive(
                  child: isContactsLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                  color: Color(0xffF71B4E))))
                      : Container(
                          child: Column(
                            children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                              height: 35,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              decoration: const BoxDecoration(
                                                  color: Color(0xff8A525F),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: TextField(
                                                controller: nickNameController,
                                                decoration: const InputDecoration(
                                                    isDense: true,
                                                    hintText:
                                                        "Kullanıcı adından ekle",
                                                    hintStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    border: InputBorder.none),
                                              )),
                                        ),
                                        const SizedBox(
                                          width: 14,
                                        ),
                                        SizedBox(
                                            height: 35,
                                            child: DefaultButton(
                                                onPressed: () =>
                                                    sendFriendRequestByName(
                                                        nickNameController.text,
                                                        context),
                                                text: "Ekle")),
                                        const SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                ] +
                                friendsInContact.entries
                                    .map((e) => FriendInContact(
                                          user: e.value!,
                                          contact: e.key,
                                          reset: getContacts,
                                        ))
                                    .toList(),
                          ),
                        ),
                ),
                KeepPageAlive(
                    child: isFriendsLoading
                        ? SizedBox(
                            width: double.infinity,
                            child: Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                    color: Color(0xffF71B4E))))
                        : Container(
                            child: Column(
                                children: friends
                                    .map((e) => AddedFriend(
                                          user: e,
                                        ))
                                    .toList()))),
                KeepPageAlive(
                  child: isInvitationsLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                  color: Color(0xffF71B4E))))
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: const Text(
                                  "Gönderilen İstekler",
                                  style: TextStyle(
                                      color: Color(0xffF71B4E),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              sentRequests.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      child: const Text(
                                        "Gönderilmiş arkadaş isteğin yok",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))
                                  : Column(
                                      children: sentRequests
                                          .map((e) => FriendInContact(
                                                user: e,
                                                isSent: true,
                                                reset: getSentFriendRequests,
                                              ))
                                          .toList(),
                                    ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: const Text(
                                  "Alınan İstekler",
                                  style: TextStyle(
                                      color: Color(0xffF71B4E),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              recievedRequests.isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(5),
                                      child: const Text(
                                        "Bekleyen arkadaş isteğin yok",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))
                                  : Column(
                                      children: recievedRequests
                                          .map((e) => FriendInviteRecieved(
                                                user: e,
                                                reset: getRecievedRequests,
                                              ))
                                          .toList(),
                                    ),
                            ],
                          ),
                        ),
                ),
              ])),
        ));
  }
}
