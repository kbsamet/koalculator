import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/groups/group_profile_friend_view.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/screens/group_screens/add_member_screen.dart';
import 'package:koalculator/services/users.dart';

import '../../models/group.dart';
import '../../services/groups.dart';
import '../dashboard.dart';
import 'edit_group_screen.dart';

class GroupProfileScreen extends StatefulWidget {
  final Group group;
  const GroupProfileScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  List<KoalUser> users = [];
  String? imageUrl;

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

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff1B1C26),
        child: SafeArea(
            child: Scaffold(
          backgroundColor: const Color(0xff1B1C26),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditGroupScreen(group: widget.group))),
                        child: const Text(
                          "Düzenle",
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
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: const BoxDecoration(
                          color: Color(0xff292A33), shape: BoxShape.circle),
                      child: imageUrl == null
                          ? Container()
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
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
                              )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  widget.group.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 36),
                ),
                const Divider(
                  color: Color(0xffF71B4E),
                  indent: 60,
                  endIndent: 60,
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
                                    GroupProfileFriendView(
                                      user: e,
                                    ),
                                  ],
                                ))
                            .toList())),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: DefaultButton(
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddMemberScreen(
                                      group: widget.group,
                                    ))),
                        text: "Üye Ekle")),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: DefaultButton(
                        onPressed: () {
                          leaveGroup(widget.group.id!);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Dashboard()),
                              (route) => false);
                        },
                        text: "Gruptan Çık")),
              ],
            ),
          ),
        )));
  }
}
