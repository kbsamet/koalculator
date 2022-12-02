import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/debt.dart';

class FriendDebtDetailListView extends StatelessWidget {
  final Debt debt;
  const FriendDebtDetailListView({Key? key, required this.debt})
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
            Text(
              debt.description,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            ? "+ ${debt.amount} ₺"
                            : "- ${debt.amount} ₺",
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
