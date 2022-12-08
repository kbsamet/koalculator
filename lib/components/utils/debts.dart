import 'package:firebase_auth/firebase_auth.dart';
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
      !isSender ? friendId : FirebaseAuth.instance.currentUser!.uid);
}
