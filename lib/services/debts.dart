import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/components/dashboard/group_list_view.dart';
import 'package:koalculator/models/debt.dart';
import 'package:koalculator/models/group.dart';

final db = FirebaseFirestore.instance;

Future<Map> getDebts() async {
  Map<dynamic, dynamic> debtIds = {};
  Map<dynamic, List<Debt>> debtData = {};

  var value = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  debtIds = value.data()!["debts"];

  debtIds.forEach((key, value) {
    List<Debt> debtDetails = [];
    value.forEach((debtId) async {
      Debt debt = await getDebtDetails(debtId.toString());
      debtDetails.add(debt);
    });

    debtData[value] = debtDetails;
  });

  // for (var value in debtData.values) {
  //   List<Debt> debtDetails = [];
  //   for (var debtId in value) {
  //     Debt debt = await getDebtDetails(debtId.toString());
  //     debtDetails.add(debt);
  //   }
  //   debtData[value] = debtDetails;
  // }

  Map<dynamic, List<Debt>> a = {};

  a = await getDebtDetail(debtIds, debtData);

  print(a);
  return debtData;
}

Future<Map<dynamic, List<Debt>>> getDebtDetail(
    Map<dynamic, dynamic> debtIds, Map<dynamic, List<Debt>> debtData) async {
  debtIds.forEach((key, value) {
    List<Debt> debtDetails = [];
    value.forEach((debtId) async {
      Debt debt = await getDebtDetails(debtId.toString());
      debtDetails.add(debt);
    });

    debtData[value] = debtDetails;
  });
  return debtData;
}

Future<Debt> getDebtDetails(String id) async {
  var value = await db.collection("debts").doc(id).get();
  return Debt.fromJson(value.data()!);
}
