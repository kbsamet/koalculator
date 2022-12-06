import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/dashboard/debt_list_view.dart';
import '../../models/debt.dart';
import '../../services/debts.dart';
import '../dashboard.dart';

final db = FirebaseFirestore.instance;

class DebtHistory extends StatefulWidget {
  const DebtHistory({Key? key}) : super(key: key);

  @override
  State<DebtHistory> createState() => _DebtHistoryState();
}

class _DebtHistoryState extends State<DebtHistory> {
  Map<String, dynamic> debts = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDebts();
  }

  void resetDebts() async {
    await getDebts();
    setState(() {});
  }

  Future getDebts() async {
    Map<String, dynamic> debtIds;
    Map<String, List<Debt>> newDebts = {};

    var value = await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    debtIds = value.data()!["pastDebts"];

    for (var debts in debtIds.keys) {
      newDebts.addAll({debts: []});
      for (var element in debtIds[debts]) {
        Debt debt = await getPastDebtDetails(element.toString());
        debt.id = element;
        newDebts[debts]!.add(debt);
      }
    }
    debts = newDebts;
    setState(() {});
    print(debts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff1B1C26),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff1B1C26),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 30, color: Color(0xffF71B4E)),
              onPressed: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Dashboard(),
              )),
            ),
            title: const Text(
              "Geçmiş",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color(0xffF71B4E)),
            ),
          ),
          body: ListView(
              children: debts.keys.map((key) {
            return Column(
              children: [
                DebtListView(
                  debts: debts[key],
                  friendId: key.toString(),
                  resetDebts: resetDebts,
                ),
                const SizedBox(
                  height: 5,
                )
              ],
            );
          }).toList()),
        ));
  }
}
