import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';

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
                        child: Image.network(
                          imageUrl!,
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
    );
  }
}
