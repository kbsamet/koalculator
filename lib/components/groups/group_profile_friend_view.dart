import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';

import '../../screens/profile_screens/profile_screen.dart';
import '../../services/images.dart';

final storage = FirebaseStorage.instance.ref();

class GroupProfileFriendView extends StatefulWidget {
  final KoalUser user;
  const GroupProfileFriendView({Key? key, required this.user})
      : super(key: key);

  @override
  State<GroupProfileFriendView> createState() => _GroupProfileFriendViewState();
}

class _GroupProfileFriendViewState extends State<GroupProfileFriendView> {
  String? imageUrl;

  void stateInit() async {
    imageUrl = await getProfilePic(widget.user.id);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    stateInit();
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
                      ? SizedBox(
                          height: 50,
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                              child: Container(
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                ),
                              )),
                        )
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
          ],
        ),
      ),
    );
  }
}
