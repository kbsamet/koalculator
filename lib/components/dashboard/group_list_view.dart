import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/models/user.dart';

import '../../screens/group_screens/group_detail_screen.dart';

final storage =
    FirebaseStorage.instanceFor(bucket: "gs://koalculator-5584c.appspot.com");

final db = FirebaseFirestore.instance;

class GroupListView extends StatefulWidget {
  final Group group;
  const GroupListView({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupListView> createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  List<KoalUser> users = [];
  String imageUrl = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();
    getUserNames();
  }

  void getUserNames() async {
    for (var element in widget.group.users) {
      var res = await db.collection("users").doc(element).get();
      print(res);
      setState(() {
        users.add(KoalUser.fromJson(res.data()!));
      });
    }
  }

  void getImage() async {
    String url = await FirebaseStorage.instance
        .refFromURL(widget.group.pic)
        .getDownloadURL();
    setState(() {
      imageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const GroupDetailScreen())),
      child: Container(
          color: const Color(0xff292A33),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                  width: 65,
                  height: 65,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xffF71B4E)),
                    ),
                    /*
                    const Divider(
                      color: Color(0xffF71B4E),
                      thickness: 1.0,
                      endIndent: 30,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    */
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: users.map((e) {
                        int i = users.indexOf(e);
                        return i != widget.group.users.length - 1
                            ? Text(
                                "${e.name}, ",
                                style: const TextStyle(fontSize: 15),
                              )
                            : Text(
                                e.name,
                                style: const TextStyle(fontSize: 15),
                              );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 6,
                    )
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 30,
                color: Color(0xffF71B4E),
              )
            ],
          )),
    );
  }
}
