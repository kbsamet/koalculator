import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_button.dart';
import 'package:koalculator/models/user.dart';

import '../../models/debt.dart';

final db = FirebaseFirestore.instance;

class DebtListView extends StatefulWidget {
  final Debt debt;
  const DebtListView({Key? key, required this.debt}) : super(key: key);

  @override
  State<DebtListView> createState() => _DebtListViewState();
}

class _DebtListViewState extends State<DebtListView> {
  bool isSender = false;
  KoalUser? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isSender = widget.debt.senderId == FirebaseAuth.instance.currentUser!.uid;
    });
    getUser();
  }

  void getUser() async {
    var res = await db
        .collection("users")
        .doc(isSender ? widget.debt.recieverId : widget.debt.senderId)
        .get();
    setState(() {
      user = KoalUser.fromJson(res.data()!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff292A33),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              user == null
                  ? isSender
                      ? widget.debt.recieverId
                      : widget.debt.senderId
                  : user!.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  !isSender
                      ? "+ ${widget.debt.amount} ₺"
                      : "- ${widget.debt.amount} ₺",
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
                DebtButton(onPressed: () {}, isPositive: !isSender),
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
        ));
  }
}
