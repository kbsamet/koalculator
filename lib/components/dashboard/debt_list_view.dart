import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_button.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/components/empty_button.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/screens/debt_screens/friend_debt_detail.dart';
import 'package:koalculator/services/debts.dart';

import 'package:koalculator/services/users.dart';

import '../../models/debt.dart';
import '../header.dart';

final db = FirebaseFirestore.instance;

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
  bool isSender = false;
  Debt? totalDebt;
  KoalUser? user;
  TextEditingController debtAmountController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFriend();
    calculateDebts();
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
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debts != widget.debts && widget.debts.isNotEmpty) {
      calculateDebts();
    }
  }

  void getFriend() async {
    KoalUser? friend = await getUser(widget.friendId);
    setState(() {
      user = friend!;
    });
  }

  void calculateDebts() {
    num total = 0;
    for (var element in widget.debts) {
      total += (element.recieverId == FirebaseAuth.instance.currentUser!.uid
              ? 1
              : -1) *
          element.amount;
    }
    setState(() {
      isSender = total < 0;
      totalDebt = Debt(
          total,
          "31",
          "sex",
          isSender ? widget.friendId : FirebaseAuth.instance.currentUser!.uid,
          !isSender ? widget.friendId : FirebaseAuth.instance.currentUser!.uid);
    });
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
                    Text(
                      user == null
                          ? isSender
                              ? totalDebt!.recieverId
                              : totalDebt!.senderId
                          : user!.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
                                onPressed: () {
                                  if (isSender) {
                                    showPayDebtDialog();
                                    widget.resetDebts();
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
