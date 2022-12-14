import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/components/utils/keep_alive.dart';
import 'package:koalculator/models/debt.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/screens/friend_screens/friends_screen.dart';
import 'package:koalculator/screens/profile_screens/profile_screen.dart';
import 'package:koalculator/services/groups.dart';
import 'package:permission_handler/permission_handler.dart';

import '../components/dashboard/group_list_view.dart';
import '../components/dashboard/navbar.dart';
import '../services/debts.dart';
import '../services/users.dart';

final db = FirebaseFirestore.instance;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Group> groups = [];
  Map<String, dynamic> debts = {};
  bool isGroupsLoading = false;
  bool isDebtsLoading = false;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
    getDebts();
    init();
  }

  void resetDebts() async {
    await Future.delayed(const Duration(seconds: 2));
    await getDebts();
  }

  void init() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      Permission.contacts.request();
    }
  }

  Future getDebts() async {
    setState(() {
      isDebtsLoading = true;
    });
    Map<String, dynamic> debtIds;
    Map<String, List<Debt>> newDebts = {};

    var value = await getAllUsersById();
    debtIds = value.data()!["debts"];

    for (var debts in debtIds.keys) {
      newDebts.addAll({debts: []});
      for (var element in debtIds[debts]) {
        Debt debt = await getDebtDetails(element.toString());
        debt.id = element;
        newDebts[debts]!.add(debt);
      }
    }
    debts = newDebts;
    setState(() {
      isDebtsLoading = false;
    });
  }

  Future getGroupDetails() async {
    setState(() {
      isGroupsLoading = true;
    });
    List<Group> newGroups = await getGroups();
    setState(() {
      groups = newGroups;
      isGroupsLoading = false;
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
            floatingActionButton: FloatingActionButton(
              //Floating action button on Scaffold
              onPressed: () {
                getGroupDetails();
                getDebts();
              },
              backgroundColor: const Color(0xffF71B4E),
              child: const Icon(Icons.home),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: const BottomNavbar(),
            appBar: AppBar(
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.group,
                    size: 25,
                  ),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FriendsScreen())),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    const Text(
                      "Koalculator",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person,
                        size: 25,
                      ),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen())),
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
              KeepPageAlive(
                  child: isGroupsLoading
                      ? SizedBox(
                          width: double.infinity,
                          child: Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                  color: Color(0xffF71B4E))))
                      : Column(
                          children: groups
                              .map(
                                (e) => GroupListView(group: e),
                              )
                              .toList())),
              KeepPageAlive(
                child: isDebtsLoading
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
                            SizedBox(
                              child: DebtListView(
                                debts: debts[key],
                                friendId: key.toString(),
                                resetDebts: resetDebts,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            )
                          ],
                        );
                      }).toList()),
              ),
            ]),
          )),
    );
  }
}
