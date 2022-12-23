import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_button.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/components/empty_button.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/screens/debt_screens/friend_debt_detail.dart';
import 'package:koalculator/screens/profile_screens/profile_screen.dart';
import 'package:koalculator/services/debts.dart';
import 'package:koalculator/services/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/debt.dart';
import '../../services/friends.dart';
import '../../services/images.dart';
import '../../services/users.dart';
import '../header.dart';
import '../utils/debts.dart';

class DebtListView extends StatefulWidget {
  final List<dynamic> debts;
  final String friendId;
  final VoidCallback resetDebts;
  const DebtListView(
      {Key? key,
      required this.debts,
      required this.friendId,
      required this.resetDebts})
      : super(key: key);

  @override
  State<DebtListView> createState() => _DebtListViewState();
}

class _DebtListViewState extends State<DebtListView> {
  String? imageUrl;
  bool isSender = false;
  Debt? totalDebt;
  KoalUser? user;
  TextEditingController debtAmountController = TextEditingController();
  @override
  void initState() {
    super.initState();

    stateInit();
  }

  void stateInit() async {
    totalDebt = calculateDebts(isSender, widget.debts, widget.friendId);
    isSender = totalDebt!.amount < 0;
    user = await getFriend(widget.friendId);
    imageUrl = await getProfilePic(widget.friendId);
    setState(() {});
  }

  void showPayDebtDialog() async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding: const EdgeInsets.all(30),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        backgroundColor: const Color(0xff1B1C26),
        title: const Header(text: 'Ödenecek Miktarı Griniz'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DefaultTextInput(
                  onlyNumber: true,
                  noMargin: true,
                  hintText: "Ödediğin miktar",
                  noIcon: true,
                  controller: debtAmountController,
                  icon: Icons.attach_money),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: EmptyButton(
                      text: 'İptal',
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: DefaultButton(
                      text: 'Öde',
                      onPressed: () async {
                        bool res = await payDebtsByAmount(
                            widget.debts as List<Debt>,
                            double.parse(debtAmountController.text).floor(),
                            context);
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Borçlarınız başarıyla ödendi!")));
                        }
                        Navigator.pop(context, 'OK');
                        widget.resetDebts();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DebtListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debts != widget.debts && widget.debts.isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return totalDebt == null
        ? Container()
        : InkWell(
            onTap: () {
              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) =>
                        FriendDebtDetail(friend: user!, id: widget.friendId))));
              }
            },
            child: Container(
                color: const Color(0xff292A33),
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            KoalUser? friend = await getUser(widget.friendId);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) =>
                                    ProfileScreen(user: friend))));
                          },
                          child: Container(
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              border: Border.all(color: Colors.black),
                            ),
                            child: imageUrl == null
                                ? SizedBox(
                                    height: 40,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100)),
                                        child: Container(
                                          child: const Icon(
                                            Icons.person,
                                            size: 32,
                                          ),
                                        )),
                                  )
                                : ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
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
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          user == null ? "Yükleniyor" : user!.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        totalDebt!.amount == 0
                            ? const Text("0₺",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24))
                            : Text(
                                !isSender
                                    ? "+ ${totalDebt!.amount} ₺"
                                    : "- ${-totalDebt!.amount} ₺",
                                style: TextStyle(
                                    color: !isSender
                                        ? const Color(0xff34A853)
                                        : const Color(0xffF71B4E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                        const SizedBox(
                          width: 20,
                        ),
                        totalDebt!.amount == 0
                            ? Container()
                            : DebtButton(
                                onPressed: () async {
                                  if (isSender) {
                                    showPayDebtDialog();
                                  } else {
                                    KoalUser? otherUser =
                                        await getUser(widget.friendId);
                                    if (otherUser!.token != "") {
                                      KoalUser? thisUser = await getUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid);

                                      var prefs =
                                          await SharedPreferences.getInstance();
                                      String? lastRemindDate = prefs.getString(
                                          "lastRemindDate${thisUser!.id}");

                                      // check if last reminded date isn't null and if it is less than 1 day ago
                                      if (lastRemindDate != null &&
                                          DateTime.parse(lastRemindDate)
                                                  .difference(DateTime.now())
                                                  .inDays <
                                              1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Dürtü gönderme limitine ulaştınız. Lütfen 1 gün sonra tekrar deneyin.")));
                                        return;
                                      }

                                      sendPushMessage(
                                          "Dürtü",
                                          "${thisUser.name} sizi borcunuzu ödemeniz için dürttü.",
                                          otherUser.token!);
                                      addNewNotfication("debt", otherUser.id!);

                                      prefs.setString(
                                          "lastRemindDate${thisUser.id}",
                                          DateTime.now().toString());

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Dürtü gönderildi.")));
                                    }
                                  }
                                },
                                isPositive: !isSender),
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 30,
                          color: Color(0xffF71B4E),
                        )
                      ],
                    )
                  ],
                )),
          );
  }
}
