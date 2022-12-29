import 'package:flutter/material.dart';
import 'package:koalculator/services/users.dart';

import '../../components/groups/group_friend_view.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/friends.dart';
import '../../services/groups.dart';
import '../dashboard.dart';

class AddMemberScreen extends StatefulWidget {
  final Group group;
  const AddMemberScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<KoalUser> friends = [];
  List<KoalUser> addedFriends = [];

  @override
  void initState() {
    super.initState();
    getUserFriends();
  }

  void getUserFriends() async {
    List<KoalUser> newFriends = await getFriends();
    List<KoalUser> removed = [];
    for (var friend in newFriends) {
      var res = await getUserByFriendId(friend.id);
      if (res.data()!["groups"] != null &&
          (res.data()!["groups"] as List).contains(widget.group.id)) {
        removed.add(friend);
      }
    }

    for (var element in removed) {
      newFriends.remove(element);
    }

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

  void addUsers() async {
    for (var element in addedFriends) {
      print(widget.group.id!);
      print(element);
      await addToGroup(widget.group.id!, element);
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false);
  }

  String getAddedNames() {
    String addedNames = "";
    for (var element in addedFriends) {
      addedNames += "${element.name}, ";
    }

    return addedNames.substring(0, addedNames.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff1B1C26),
        child: SafeArea(
            child: Scaffold(
                backgroundColor: const Color(0xff1B1C26),
                body: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xffF71B4E),
                            ),
                          ),
                          InkWell(
                            onTap: addUsers,
                            child: const Text(
                              "Onayla",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffF71B4E),
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: 35,
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                            color: Color(0xff8A525F),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
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
                    Expanded(
                        child: ListView(
                            children: friends
                                .map((e) => GroupFriendView(
                                      user: e,
                                      addUser: addOrRemoveFriend,
                                    ))
                                .toList())),
                  ],
                ))));
  }
}
