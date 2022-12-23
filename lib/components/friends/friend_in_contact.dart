import 'package:cached_network_image/cached_network_image.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/friends.dart';

import '../../screens/profile_screens/profile_screen.dart';
import '../../services/images.dart';

final storage = FirebaseStorage.instance.ref();

class FriendInContact extends StatefulWidget {
  final KoalUser user;
  final Contact? contact;
  final bool isSent;
  final VoidCallback reset;
  const FriendInContact(
      {Key? key,
      required this.user,
      this.contact,
      this.isSent = false,
      required this.reset})
      : super(key: key);

  @override
  State<FriendInContact> createState() => _FriendInContactState();
}

class _FriendInContactState extends State<FriendInContact> {
  bool isSent = false;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    stateInit();
  }

  void stateInit() async {
    imageUrl = await getProfilePic(widget.user.id);
    isSent = widget.isSent;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(user: widget.user))),
      child: Container(
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
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: imageUrl == null
                      ? SizedBox(
                          height: 40,
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                              child: Container(
                                child: const Icon(
                                  Icons.person,
                                  size: 32,
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
                  width: 20,
                ),
                isSent
                    ? Text(
                        widget.user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            widget.contact!.displayName!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xffB0B0B0)),
                          )
                        ],
                      ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: GestureDetector(
                onTap: () async {
                  if (isSent) return;
                  await sendFriendRequest(widget.user.id!, context);
                  setState(() {
                    isSent = true;
                  });
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: isSent
                            ? [const Color(0xff0F1120), const Color(0xff0F1120)]
                            : [
                                const Color(0xffFD4365),
                                const Color(0xffFD2064)
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Text(
                    isSent ? "İstek Gönderildi" : "Arkadaş Ekle",
                    style: const TextStyle(
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
        ),
      ),
    );
  }
}
