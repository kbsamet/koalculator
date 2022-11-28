import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/models/debt.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/screens/friend_screens/friends_screen.dart';
import 'package:koalculator/screens/group_screens/create_group.dart';
import 'package:koalculator/services/groups.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/dashboard/group_list_view.dart';
import '../components/default_button.dart';
import 'main_page.dart';

final db = FirebaseFirestore.instance;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Group> groups = [];
  List<Debt> debts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupDetails();
    init();
  }

  void init() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      Permission.contacts.request();
    }
  }

  // void getDebts() async {
  //   List<dynamic> debtIds = [];

  //   var value = await db
  //       .collection("users")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   debtIds = value.data()!["debts"];

  //   for (var element in debtIds) {
  //     Debt debt = await getDebtDetails(element.toString());
  //     setState(() {
  //       debts.add(debt);
  //     });
  //   }
  //   print(debts.length);
  // }

  Future<Debt> getDebtDetails(String id) async {
    var value = await db.collection("debts").doc(id).get();
    return Debt.fromJson(value.data()!);
  }

  void getGroupDetails() async {
    List<Group> newGroups = await getGroups();
    print(newGroups);
    setState(() {
      groups = newGroups;
    });
  }

  final tabBar = const TabBar(
      indicatorColor: Color(0xffF71B4E),
      labelColor: Color(0xffFF6D8F),
      unselectedLabelColor: Color(0xffAFAFAF),
      labelStyle: TextStyle(
          fontWeight: FontWeight.bold, fontFamily: "QuickSand", fontSize: 16),
      tabs: [
        Tab(
          text: "Gruplar",
        ),
        Tab(
          text: "Kişiler",
        )
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff303139),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                  titleSpacing: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.group,
                      size: 25,
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const FriendsScreen())),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      const Text(
                        "Koalculator",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          size: 25,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                  backgroundColor: const Color(0xff303139),
                  bottom: PreferredSize(
                    preferredSize: tabBar.preferredSize,
                    child: Material(
                      color: const Color(0xff303139),
                      child: tabBar,
                    ),
                  )),
              body: TabBarView(children: [
                Column(
                  children: groups
                          .map(
                            (e) => GroupListView(group: e),
                          )
                          .toList()
                          .cast<Widget>() +
                      <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        DefaultButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const CreateGroup()));
                            },
                            text: "Grup Oluştur"),
                        const SizedBox(
                          height: 10,
                        ),
                        DefaultButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const MainPage()));
                            },
                            text: "Çık")
                      ],
                ),
                Column(
                  children: debts
                      .map((e) => Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              DebtListView(debt: e),
                            ],
                          ))
                      .toList(),
                ),
              ])),
        ));
  }
}
