import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:koalculator/models/debt.dart';

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

Future<Debt> getPastDebtDetails(String id) async {
  var value = await db.collection("pastDebts").doc(id).get();
  return Debt.fromJson(value.data()!);
}

void createDebt(Debt debt) async {
  var ref = await db.collection("debts").add(debt.toJson());

  db.collection("users").doc(debt.recieverId).set({
    "debts": {
      debt.senderId: FieldValue.arrayUnion([ref.id])
    }
  }, SetOptions(merge: true));

  db.collection("users").doc(debt.senderId).set({
    "debts": {
      debt.recieverId: FieldValue.arrayUnion([ref.id])
    }
  }, SetOptions(merge: true));
}

Future<List<Debt>> getDebtsByFriendId(String id) async {
  List<Debt> debts = [];

  var user = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  Map userDebts = user.data()!["debts"] as Map;
  if (!userDebts.containsKey(id)) {
    print("No Debt Found for friend");
    return [];
  } else {
    for (var element in (userDebts[id] as List)) {
      debts.add(await getDebtDetails(element));
    }
    return debts;
  }
}

Future<List<Debt>> getPastDebtsByFriendId(String id) async {
  List<Debt> debts = [];

  var user = await db
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  Map userDebts = user.data()!["pastDebts"] as Map;
  if (!userDebts.containsKey(id)) {
    print("No Debt Found for friend");
    return [];
  } else {
    for (var element in (userDebts[id] as List)) {
      debts.add(await getPastDebtDetails(element));
    }
    return debts;
  }
}

Future payDebts(List<Debt> debts) async {
  for (var debt in debts) {
    await payDebt(debt);
  }
}

Future payDebt(Debt debt) async {
  db.collection("debts").doc(debt.id).delete();
  var newDebt = await db.collection("pastDebts").add(debt.toJson());

  await db.collection("users").doc(debt.senderId).set({
    "debts": {
      debt.recieverId: FieldValue.arrayRemove([debt.id])
    }
  }, SetOptions(merge: true));
  db.collection("users").doc(debt.senderId).set({
    "pastDebts": {
      debt.recieverId: FieldValue.arrayUnion([newDebt.id])
    }
  }, SetOptions(merge: true));

  db.collection("users").doc(debt.recieverId).set({
    "debts": {
      debt.senderId: FieldValue.arrayRemove([debt.id])
    }
  }, SetOptions(merge: true));
  db.collection("users").doc(debt.recieverId).set({
    "pastDebts": {
      debt.senderId: FieldValue.arrayUnion([newDebt.id])
    }
  }, SetOptions(merge: true));
}

// a function that pays debts by amount
Future payDebtsByAmount(List<Debt> debts, num amount, context) async {
  double totalAmount = 0;
  for (var debt in debts) {
    totalAmount += debt.amount;
  }
  if (totalAmount < amount) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Girdiğiniz tutar borçlarınızın toplamından büyük olamaz!")));
    return;
  } else {
    debts.sort((a, b) => a.amount.compareTo(b.amount));
    num remainingAmount = amount;
    while (remainingAmount > 0) {
      if (remainingAmount >= debts[0].amount) {
        Debt debt = Debt(debts[0].amount, debts[0].groupId, debts[0].recieverId,
            debts[0].senderId, debts[0].description);
        debt.id = debts[0].id;
        await payDebt(debt);
        remainingAmount -= debts[0].amount;
        debts.removeAt(0);
      } else {
        db.collection("debts").doc(debts[0].id).update({
          "amount": debts[0].amount - remainingAmount,
        });
        remainingAmount = 0;
      }
    }
  }
  return;
}
