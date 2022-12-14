import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/debts/friend_debt_detail_list_view.dart';
import 'package:koalculator/models/user.dart';

import '../../models/debt.dart';
import '../../services/debts.dart';

class FriendDebtDetail extends StatefulWidget {
  final KoalUser friend;
  final String id;
  const FriendDebtDetail({Key? key, required this.friend, required this.id})
      : super(key: key);

  @override
  State<FriendDebtDetail> createState() => _FriendDebtDetailState();
}

class _FriendDebtDetailState extends State<FriendDebtDetail> {
  List<Debt> debts = [];
  Debt? totalDebt;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initDebts();
  }

  void initDebts() async {
    setState(() {
      isLoading = true;
    });
    List<Debt> debts_ = await getDebtsByFriendId(widget.id);
    num total = 0;
    for (var element in debts_) {
      total += element.amount *
          (FirebaseAuth.instance.currentUser!.uid == element.senderId ? -1 : 1);
    }

    Debt totalDebt_ = Debt(
        total.abs(),
        "",
        total > 0 ? FirebaseAuth.instance.currentUser!.uid : widget.id,
        total < 0 ? FirebaseAuth.instance.currentUser!.uid : widget.id,
        "Toplam");
    setState(() {
      debts = debts_;
      totalDebt = totalDebt_;
      isLoading = false;
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
            body: isLoading
                ? SizedBox(
                    width: double.infinity,
                    child: Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            color: Color(0xffF71B4E))))
                : SizedBox(
                    width: double.infinity,
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Center(
                            child: Text(
                          "Aktif Borçlar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
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
                        totalDebt != null
                            ? FriendDebtDetailListView(debt: totalDebt!)
                            : Container(),
                      ],
                    ),
                  )));
  }
}
