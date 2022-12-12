import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:koalculator/components/empty_button.dart';

import '../../models/user.dart';
import '../../screens/profile_screens/profile_screen.dart';
import '../default_button.dart';

final storage = FirebaseStorage.instance.ref();

class GroupFriendEditView extends StatefulWidget {
  final KoalUser user;
  final Function(KoalUser) removeFromGroup;
  const GroupFriendEditView(
      {super.key, required this.user, required this.removeFromGroup});

  @override
  State<GroupFriendEditView> createState() => _GroupFriendEditViewState();
}

class _GroupFriendEditViewState extends State<GroupFriendEditView> {
  String? imageUrl;
  bool removed = false;

  void getProfilePic() async {
    try {
      String url =
          await storage.child("profilePics/${widget.user.id}").getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePic();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(user: widget.user))),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        color: const Color(0xff292A33),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: Colors.black),
                  ),
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
                            fit: BoxFit.fill,
                          )),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: removed
                    ? EmptyButton(text: "Çıkarıldı", onPressed: () {})
                    : DefaultButton(
                        text: "Gruptan Çıkar",
                        onPressed: () {
                          removed = true;
                          widget.removeFromGroup(widget.user);
                          setState(() {});
                        }))
          ],
        ),
      ),
    );
  }
}
