import 'package:flutter/material.dart';
import 'package:koalculator/components/debts/debt_history_list_view.dart';
import 'package:koalculator/services/users.dart';

import '../../models/debt.dart';
import '../../services/debts.dart';

class DebtHistory extends StatefulWidget {
  const DebtHistory({Key? key}) : super(key: key);

  @override
  State<DebtHistory> createState() => _DebtHistoryState();
}

class _DebtHistoryState extends State<DebtHistory> {
  Map<String, dynamic> debts = {};
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getDebts();
  }

  Future getDebts() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> debtIds;
    Map<String, List<Debt>> newDebts = {};

    var value = await getAllUsersById();
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
    setState(() {
      isLoading = false;
    });
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
                onPressed: () => Navigator.of(context).pop()),
            title: const Text(
              "Geçmiş",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color(0xffF71B4E)),
            ),
          ),
          body: isLoading
              ? SizedBox(
                  width: double.infinity,
                  child: Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                          color: Color(0xffF71B4E))))
              : ListView(
                  children: debts.keys.map((key) {
                  return Column(
                    children: [
                      DebtHistoryListView(
                        debts: debts[key],
                        friendId: key.toString(),
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
