import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/friends.dart';

import '../../services/images.dart';

final storage = FirebaseStorage.instance.ref();

class FriendInviteRecieved extends StatefulWidget {
  final KoalUser user;
  final VoidCallback reset;
  const FriendInviteRecieved(
      {Key? key, required this.user, required this.reset})
      : super(key: key);

  @override
  State<FriendInviteRecieved> createState() => _FriendInviteRecievedState();
}

class _FriendInviteRecievedState extends State<FriendInviteRecieved> {
  bool responded = false;
  bool isSent = false;
  String? imageUrl;

  void stateInit() async {
    imageUrl = await getProfilePic(widget.user.id);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stateInit();
  }

  @override
  Widget build(BuildContext context) {
    return responded
        ? Container()
        : Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: const Color(0xff292A33),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
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
                      width: 20,
                    ),
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                      child: GestureDetector(
                        onTap: () async {
                          if (responded) return;
                          await denyFriendRequest(widget.user.id!);
                          widget.reset();
                          setState(() {
                            responded = true;
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xff0F1120), Color(0xff0F1120)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: const Text(
                            "Reddet",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: "QuickSand"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      child: GestureDetector(
                        onTap: () async {
                          if (responded) false;
                          await acceptFriendRequest(widget.user.id!);
                          widget.reset();
                          setState(() {
                            responded = true;
                          });
                        },
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xffFD4365), Color(0xffFD2064)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: const Text(
                            "Kabul Et",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: "QuickSand"),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
