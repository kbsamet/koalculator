import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_button.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/screens/debt_screens/friend_debt_detail.dart';
import 'package:koalculator/services/users.dart';

import '../../models/debt.dart';

final db = FirebaseFirestore.instance;

class DebtListView extends StatefulWidget {
  final List<dynamic> debts;
  final String friendId;
  const DebtListView({Key? key, required this.debts, required this.friendId})
      : super(key: key);

  @override
  State<DebtListView> createState() => _DebtListViewState();
}

class _DebtListViewState extends State<DebtListView> {
  bool isSender = false;
  Debt? totalDebt;
  KoalUser? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFriend();
    calculateDebts();
  }

  void getFriend() async {
    KoalUser? friend = await getUser(widget.friendId);
    setState(() {
      user = friend!;
    });
  }

  void calculateDebts() {
    num total = 0;
    print(widget.debts);
    for (var element in widget.debts) {
      print(element.amount);
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
                                onPressed: () {}, isPositive: !isSender),
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
