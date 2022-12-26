import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/debt.dart';

class FriendDebtDetailListView extends StatelessWidget {
  final Debt debt;
  final bool isPast;
  const FriendDebtDetailListView(
      {Key? key, required this.debt, this.isPast = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff292A33),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  debt.description,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 10,
                ),
                debt.createdAt != null
                    ? Text(
                        Jiffy(debt.createdAt!.toString()).format("dd/MM/yyyy"),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      )
                    : Container(),
              ],
            ),
            Row(
              children: [
                debt.amount == 0
                    ? const Text("0₺",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24))
                    : Text(
                        debt.recieverId ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? "+ ${isPast ? debt.originalAmount : debt.amount} ₺"
                            : "- ${isPast ? debt.originalAmount : debt.amount} ₺",
                        style: TextStyle(
                            color: debt.recieverId ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? const Color(0xff34A853)
                                : const Color(0xffF71B4E),
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                const SizedBox(
                  width: 20,
                ),
              ],
            )
          ],
        ));
  }
}
