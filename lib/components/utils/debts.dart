import 'package:firebase_auth/firebase_auth.dart';

import '../../models/debt.dart';

dynamic calculateDebts(bool isSender, List<dynamic> debts, String friendId) {
  num total = 0;
  for (var element in debts) {
    total += (element.recieverId == FirebaseAuth.instance.currentUser!.uid
            ? 1
            : -1) *
        element.amount;
  }

  isSender = total < 0;
  return Debt(
      total,
      "31",
      "sex",
      isSender ? friendId : FirebaseAuth.instance.currentUser!.uid,
      !isSender ? friendId : FirebaseAuth.instance.currentUser!.uid,
      total);
}
