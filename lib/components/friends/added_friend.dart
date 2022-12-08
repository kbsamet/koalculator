import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/images.dart';

final storage = FirebaseStorage.instance.ref();

class AddedFriend extends StatefulWidget {
  final KoalUser user;
  const AddedFriend({Key? key, required this.user}) : super(key: key);

  @override
  State<AddedFriend> createState() => _AddedFriendState();
}

class _AddedFriendState extends State<AddedFriend> {
  String? imageUrl;
  @override
  void initState() {
    super.initState();
  }

  void stateInit() async {
    imageUrl = await getProfilePic(widget.user.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
        ],
      ),
    );
  }
}
