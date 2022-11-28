import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/group_chat_bubble.dart';

import '../../models/group.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String? imageUrl;
  final tabBar = const TabBar(
      indicatorColor: Color(0xffF71B4E),
      labelColor: Color(0xffFF6D8F),
      unselectedLabelColor: Color(0xffAFAFAF),
      labelStyle: TextStyle(
          fontWeight: FontWeight.bold, fontFamily: "QuickSand", fontSize: 16),
      tabs: [
        Tab(
          text: "Ödeme Geçmişi",
        ),
        Tab(
          text: "Mevcut Borçlar",
        )
      ]);

  void getImage() async {
    if (widget.group.pic != null) {
      String url = await FirebaseStorage.instance
          .refFromURL(widget.group.pic!)
          .getDownloadURL();

      setState(() {
        imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff303139),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                  leadingWidth: 30,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 30, color: Color(0xffF71B4E)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  toolbarHeight: 60,
                  backgroundColor: const Color(0xff303139),
                  title: GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: imageUrl == null
                                  ? Image.asset(
                                      "assets/images/group.png",
                                      fit: BoxFit.fill,
                                      width: 60,
                                      height: 60,
                                    )
                                  : Image.network(
                                      imageUrl!,
                                      fit: BoxFit.fill,
                                      width: 60,
                                      height: 60,
                                    ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Zombiler",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xffF71B4E)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  bottom: PreferredSize(
                    preferredSize: tabBar.preferredSize,
                    child: Material(
                      color: const Color(0xff303139),
                      child: tabBar,
                    ),
                  )),
              body: TabBarView(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: const [
                      GroupChatBubble(
                          sender: "Sego",
                          isSender: false,
                          reciever: "Emre",
                          amount: 100),
                    ],
                  ),
                ),
                Container(),
              ])),
        ));
  }
}
