import 'package:flutter/material.dart';
import 'package:koalculator/screens/debt_screens/friend_debt_history.dart';

import '../../models/user.dart';
import '../../services/users.dart';

class DebtHistoryListView extends StatefulWidget {
  final List<dynamic> debts;
  final String friendId;
  const DebtHistoryListView(
      {super.key, required this.debts, required this.friendId});

  @override
  State<DebtHistoryListView> createState() => _DebtHistoryListViewState();
}

class _DebtHistoryListViewState extends State<DebtHistoryListView> {
  KoalUser? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFriend();
  }

  void getFriend() async {
    KoalUser? friend = await getUser(widget.friendId);
    setState(() {
      user = friend!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (user != null) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: ((context) =>
                  FriendDebtHistory(friend: user!, id: widget.friendId))));
        }
      },
      child: Container(
          color: const Color(0xff292A33),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user == null ? "Yükleniyor..." : user!.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(),
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
          )),
    );
  }
}
