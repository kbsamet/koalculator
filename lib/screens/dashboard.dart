import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/components/header.dart';
import 'package:koalculator/components/utils/keep_alive.dart';
import 'package:koalculator/config/firebase_config.dart';
import 'package:koalculator/models/debt.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/screens/friend_screens/friends_screen.dart';
import 'package:koalculator/screens/profile_screens/profile_screen.dart';
import 'package:koalculator/services/groups.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int friendNotifications = 0;
  int debtNotifications = 0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await getGroupDetails();
    await getDebts();
    await initFirebase();
    getNotifications();
    init();
  }

  void getNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      friendNotifications = prefs.getInt("friendNotifications") == null
          ? 0
          : prefs.getInt("friendNotifications") as int;
      debtNotifications = prefs.getInt("debtNotifications") == null
          ? 0
          : prefs.getInt("debtNotifications") as int;
    });

    print(friendNotifications);
  }

  void resetDebts() async {
    await Future.delayed(const Duration(seconds: 2));
    await getDebts();
  }

  void init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    var status = await Permission.contacts.status;
    if (status.isDenied) {
      Permission.contacts.request();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
      var prefs = await SharedPreferences.getInstance();
      print(remoteMessage.data['type']);

      if (remoteMessage.data['type'] == "debt") {
        int debtNotifications = prefs.get("debtNotifications") == null
            ? 0
            : prefs.get("debtNotifications") as int;
        prefs.setInt("debtNotifications", debtNotifications + 1);
      } else if (remoteMessage.data['type'] == "friend") {
        int friendNotifications = prefs.get("friendNotifications") == null
            ? 0
            : prefs.get("friendNotifications") as int;
        prefs.setInt("friendNotifications", friendNotifications + 1);
      }
      print(prefs.getInt("friendNotifications"));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      getDebts();
      getGroupDetails();
    });
  }

  Future getDebts() async {
    setState(() {
      isDebtsLoading = true;
    });
    try {
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
      print(debts);
      setState(() {
        isDebtsLoading = false;
      });
    } catch (e) {
      setState(() {
        isDebtsLoading = false;
      });
    }
  }

  Future getGroupDetails() async {
    setState(() {
      isGroupsLoading = true;
    });
    try {
      List<Group> newGroups = await getGroups();

      setState(() {
        groups = newGroups;
        isGroupsLoading = false;
      });
    } catch (e) {
      setState(() {
        isGroupsLoading = false;
      });
    }
  }

  final tabBar = TabBar(
      indicatorColor: const Color(0xffF71B4E),
      labelColor: const Color(0xffFF6D8F),
      unselectedLabelColor: const Color(0xffAFAFAF),
      labelStyle: const TextStyle(
          fontWeight: FontWeight.bold, fontFamily: "QuickSand", fontSize: 16),
      tabs: [
        const Tab(
          text: "Gruplar",
        ),
        Tab(
          child: SizedBox(
            width: 60,
            child: Stack(
              children: [
                const Text("Borçlar"),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffF71B4E)),
                    child: const Center(),
                  ),
                )
              ],
            ),
          ),
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
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                prefs.setInt("friendNotifications", 5);
                getNotifications();
                getGroupDetails();
                getDebts();
              },
              backgroundColor: const Color(0xffF71B4E),
              child: const Icon(Icons.home),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavbar(
              areGroupsEmpty: groups.isEmpty,
            ),
            appBar: AppBar(
                titleSpacing: 0,
                leading: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.group,
                        size: 25,
                      ),
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FriendsScreen(
                                  notifications: friendNotifications,
                                  onNotificationChange: getNotifications,
                                )));
                      },
                    ),
                    friendNotifications > 0
                        ? Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffF71B4E)),
                              child: Center(
                                child: Text(
                                  friendNotifications.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
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
                    child: TabBar(
                        onTap: (value) async {
                          print(value);
                          if (value == 1) {
                            var prefs = await SharedPreferences.getInstance();
                            prefs.setInt("debtNotifications", 0);
                            setState(() {
                              debtNotifications = 0;
                            });
                          }
                        },
                        indicatorColor: const Color(0xffF71B4E),
                        labelColor: const Color(0xffFF6D8F),
                        unselectedLabelColor: const Color(0xffAFAFAF),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "QuickSand",
                            fontSize: 16),
                        tabs: [
                          const Tab(
                            text: "Gruplar",
                          ),
                          Tab(
                            child: SizedBox(
                              width: 70,
                              height: 80,
                              child: Stack(
                                children: [
                                  const Positioned(
                                      bottom: 15, child: Text("Borçlar")),
                                  debtNotifications > 0
                                      ? Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffF71B4E)),
                                            child: Center(
                                              child: Text(
                                                debtNotifications.toString(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        ]),
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
                      : groups.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              child: const Header(text: "Hiç Grubun Yok"))
                          : ListView(
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
                    : debts.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            child: const Header(text: "Hiç Borcun Yok"))
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
                                ),
                              ],
                            );
                          }).toList()),
              ),
            ]),
          )),
    );
  }
}
