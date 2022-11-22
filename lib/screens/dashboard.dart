import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_list_view.dart';
import 'package:koalculator/components/dashboard/group_list_view.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  void getGroups() async {}

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
                  toolbarHeight: 0,
                  backgroundColor: const Color(0xff303139),
                  /*title: SafeArea(
                    child: Container(
                      color: const Color(0xff1B1C26),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Koalculator",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 36),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              color: Color(0xffF71B4E),
                              indent: 30,
                              endIndent: 30,
                              thickness: 2,
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]),
                    ),
                  ),
                  */
                  bottom: PreferredSize(
                    preferredSize: tabBar.preferredSize,
                    child: Material(
                      color: const Color(0xff303139),
                      child: tabBar,
                    ),
                  )),
              body: TabBarView(children: [
                Column(
                  children: const [
                    SizedBox(
                      height: 20,
                    ),
                    GroupListView(
                      groupName: "Zombiler",
                      memberNames: ["Emre", "Samet", "Sego"],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GroupListView(
                      groupName: "Seba",
                      memberNames: ["Sinan", "Sego"],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GroupListView(
                      groupName: "Sert",
                      memberNames: ["Kerre", "Ege hoca"],
                    ),
                  ],
                ),
                Column(
                  children: const [
                    SizedBox(
                      height: 20,
                    ),
                    DebtListView(name: "Emre", value: 100),
                    SizedBox(
                      height: 20,
                    ),
                    DebtListView(name: "Sego", value: -50),
                    SizedBox(
                      height: 20,
                    ),
                    DebtListView(name: "Sinan", value: -2000)
                  ],
                ),
              ])),
        ));
  }
}
