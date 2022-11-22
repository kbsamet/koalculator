import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/group_chat_bubble.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({Key? key}) : super(key: key);
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
                    onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const GroupDetailScreen())),
                    child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                "assets/images/Zombiler.jpg",
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
