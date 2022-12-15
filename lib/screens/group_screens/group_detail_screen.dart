import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/group_chat_bubble.dart';
import 'package:koalculator/components/utils/keep_alive.dart';
import 'package:koalculator/screens/group_screens/group_profile.dart';
import 'package:koalculator/services/payments.dart';
import 'package:koalculator/services/users.dart';

import '../../components/dashboard/debt_list_view.dart';
import '../../helpers/imageHelper.dart';
import '../../models/debt.dart';
import '../../models/group.dart';
import '../../models/payment.dart';
import '../../services/debts.dart';

final storage = FirebaseStorage.instance.ref();

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
  Map<String, dynamic> debts = {};
  bool isDebtsLoading = false;

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
          text: "Kişiler",
        )
      ]);

  @override
  void initState() {
    super.initState();
    getPayments();
    getDebts();
    getProfilePic();
  }

  Future getDebts() async {
    setState(() {
      isDebtsLoading = true;
    });
    Map<dynamic, dynamic> debtIds;
    Map<String, List<Debt>> newDebts = {};

    debtIds = await getDebtsIds();

    for (var debts in debtIds.keys) {
      if (!widget.group.users.contains(debts)) {
        continue;
      }
      newDebts.addAll({debts: []});
      for (var element in debtIds[debts]) {
        Debt debt = await getDebtDetails(element.toString());
        debt.id = element;
        newDebts[debts]!.add(debt);
      }
    }
    debts = newDebts;
    setState(() {
      isDebtsLoading = false;
    });
  }

  void getProfilePic() async {
    try {
      String url = await refImageHelper("groupProfilePics/${widget.group.id}")
          .getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {}
  }

  void resetDebts() async {
    await Future.delayed(const Duration(seconds: 2));
    await getDebts();
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
                    // ignore: sized_box_for_whitespace
                    child: Container(
                        color: const Color(0xff303139),
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
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
                                  : CachedNetworkImage(
                                      imageUrl: imageUrl!,
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
                                children: [
                                  Text(
                                    widget.group.name,
                                    style: const TextStyle(
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
                    : KeepPageAlive(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.topCenter,
                          child: ListView(
                              clipBehavior: Clip.none,
                              shrinkWrap: true,
                              reverse: true,
                              children: payments.reversed
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
                      ),
                KeepPageAlive(
                  child: isDebtsLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                  color: Color(0xffF71B4E))))
                      : ListView(
                          children: debts.keys.map((key) {
                          return Column(
                            children: [
                              SizedBox(
                                child: DebtListView(
                                    debts: debts[key],
                                    friendId: key.toString(),
                                    resetDebts: resetDebts),
                              ),
                              const SizedBox(
                                height: 5,
                              )
                            ],
                          );
                        }).toList()),
                ),
              ])),
        ));
  }
}
