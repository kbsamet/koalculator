import 'package:flutter/material.dart';
import 'package:koalculator/services/debts.dart';

import '../../components/debts/friend_debt_detail_list_view.dart';
import '../../models/debt.dart';
import '../../models/user.dart';

class FriendDebtHistory extends StatefulWidget {
  final KoalUser friend;
  final String id;
  const FriendDebtHistory({super.key, required this.friend, required this.id});

  @override
  State<FriendDebtHistory> createState() => _FriendDebtHistoryState();
}

class _FriendDebtHistoryState extends State<FriendDebtHistory> {
  List<Debt> debts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDebts();
  }

  void initDebts() async {
    List<Debt> debts_ = await getPastDebtsByFriendId(widget.id);
    setState(() {
      debts = debts_;
    });
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.friend.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color(0xffF71B4E)),
              ),
            ),
            body: SizedBox(
              width: double.infinity,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                      child: Text(
                    "Geçmiş Borçlar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  )),
                  const Divider(
                    color: Color(0xffF71B4E),
                    thickness: 2,
                    endIndent: 50,
                    indent: 50,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: debts
                        .map((e) => FriendDebtDetailListView(debt: e))
                        .toList(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )));
  }
}
