import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/group_chat_bubble.dart';
import 'package:koalculator/screens/group_screens/group_profile.dart';
import 'package:koalculator/services/payments.dart';
import 'package:koalculator/services/users.dart';

import '../../models/group.dart';
import '../../models/payment.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<Payment> payments = [];
  String? imageUrl;
  bool isLoading = false;
  ScrollController chatController = ScrollController();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPayments();
  }

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

  void getPayments() async {
    setState(() {
      isLoading = true;
    });
    payments = await getPaymentsByGroupId(widget.group.id!);
    for (var element in payments) {
      element.reciever = await getUser(element.recieverId);
      element.sender = await getUser(element.senderId);
    }

    setState(() {
      isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    chatController.animateTo(
      chatController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
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
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => GroupProfileScreen(
                                group: widget.group,
                              )));
                    },
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
                isLoading
                    ? SizedBox(
                        width: double.infinity,
                        child: Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                                color: Color(0xffF71B4E))))
                    : Container(
                        padding: const EdgeInsets.all(10),
                        child: ListView(
                            controller: chatController,
                            children: payments
                                .map(
                                  (e) => Column(
                                    children: [
                                      GroupChatBubble(
                                          group: widget.group,
                                          senderId: e.senderId,
                                          sender: e.sender!.name,
                                          isSender: e.senderId ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                          reciever: e.reciever!.name,
                                          amount: e.amount),
                                      const SizedBox(
                                        height: 20,
                                      )
                                    ],
                                  ),
                                )
                                .toList()),
                      ),
                Container(),
              ])),
        ));
  }
}
