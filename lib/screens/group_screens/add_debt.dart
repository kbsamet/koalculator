import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/models/user.dart';

import '../../models/group.dart';

final db = FirebaseFirestore.instance;

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({Key? key}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  List<Group> groups = [];
  List<KoalUser> groupUsers = [];
  List<bool> checkedUsers = [];

  List<TextEditingController> paidControllers = [];
  List<TextEditingController> toBePaidControllers = [];
  List<bool> changedInputs = [];

  String selectedValue = "";
  TextEditingController amountController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroups();
  }

  void getGroups() async {
    List<dynamic> groupIds = [];
    var res = await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    groupIds = res.data()!["groups"];

    for (var element in groupIds) {
      var res = await db.collection("groups").doc(element).get();
      setState(() {
        groups.add(Group.fromJson(res.data()!));
      });
    }
    setState(() {
      selectedValue = groups[0].name;
      getGroupUsers(groups[0]);
    });
  }

  void onAmountChanged(String s) {
    num amount = num.parse(s);

    for (var element in toBePaidControllers) {
      element.text = (amount / toBePaidControllers.length).floor().toString();
    }
    setState(() {
      changedInputs = List.filled(toBePaidControllers.length, false);
    });
  }

  getGroupUsers(Group g) async {
    List<KoalUser> newUsers = [];
    List<TextEditingController> newPaidControllers = [];
    List<TextEditingController> newToBePaidControllers = [];
    List<bool> newChangedInputs = [];

    List<bool> newCheckedUsers = [];
    for (var i = 0; i < g.users.length; i++) {
      print(checkedUsers.length);
      if (checkedUsers.length > i && !checkedUsers[i]) continue;
      var res = await db.collection("users").doc(g.users[i]).get();
      newUsers.add(KoalUser.fromJson(res.data()!));
      newPaidControllers.add(TextEditingController());
      newToBePaidControllers.add(TextEditingController());
      newChangedInputs.add(false);
      newCheckedUsers.add(true);
    }

    setState(() {
      groupUsers = newUsers;
      paidControllers = newPaidControllers;
      toBePaidControllers = newToBePaidControllers;
      changedInputs = newChangedInputs;
      checkedUsers = newCheckedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedValue == ""
        ? Container()
        : Container(
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
                title: const Text(
                  "Borç Ekle",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Color(0xffF71B4E)),
                ),
              ),
              body: Container(
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      " Grup Seç",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      color: const Color(0xff292A33),
                      width: double.infinity,
                      child: DropdownButton(
                          itemHeight: 60,
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          value: selectedValue,
                          items: groups
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.name,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (e) {
                            getGroupUsers(groups
                                .where(
                                    (element) => element.name == e.toString())
                                .first);
                            setState(() {
                              selectedValue = e.toString();
                            });
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      " Miktar",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: DefaultTextInput(
                              noMargin: true,
                              noIcon: true,
                              hintText: "Açıklama",
                              controller: descriptionController,
                              icon: Icons.announcement_rounded),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: DefaultTextInput(
                              onChanged: onAmountChanged,
                              noIcon: true,
                              onlyNumber: true,
                              hintText: "Miktar",
                              noMargin: true,
                              controller: amountController,
                              icon: Icons.monetization_on),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //burası
                    SizedBox(
                      height: 300,
                      child: ListView(
                        children: groupUsers
                            .map((e) => Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      color: const Color(0xff292A33),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                  activeColor:
                                                      const Color(0xffDA2851),
                                                  value: checkedUsers[
                                                      groupUsers.indexOf(e)],
                                                  onChanged: (v) {
                                                    setState(() {
                                                      checkedUsers[groupUsers
                                                          .indexOf(e)] = v!;
                                                      paidControllers[groupUsers
                                                              .indexOf(e)]
                                                          .text = "";
                                                      toBePaidControllers[
                                                              groupUsers
                                                                  .indexOf(e)]
                                                          .text = "";
                                                      changedInputs =
                                                          List.filled(
                                                              toBePaidControllers
                                                                  .length,
                                                              false);
                                                    });
                                                  }),
                                              Text(
                                                e.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: !checkedUsers[
                                                            groupUsers
                                                                .indexOf(e)]
                                                        ? const Color.fromARGB(
                                                            255, 92, 92, 92)
                                                        : Colors.white),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: DefaultTextInput(
                                                  isDisabled: !checkedUsers[
                                                      groupUsers.indexOf(e)],
                                                  controller: paidControllers[
                                                      groupUsers.indexOf(e)],
                                                  icon: Icons.abc,
                                                  noIcon: true,
                                                  noMargin: true,
                                                  hintText: "Ödenen",
                                                  onlyNumber: true,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: DefaultTextInput(
                                                  isDisabled: !checkedUsers[
                                                      groupUsers.indexOf(e)],
                                                  onChanged: (s) {
                                                    print(checkedUsers);
                                                    setState(() {
                                                      changedInputs[groupUsers
                                                          .indexOf(e)] = true;
                                                      if (s == "") {
                                                        changedInputs[groupUsers
                                                                .indexOf(e)] =
                                                            false;
                                                      }
                                                    });
                                                    num changedSum = 0;
                                                    for (var i = 0;
                                                        i <
                                                            changedInputs
                                                                .length;
                                                        i++) {
                                                      changedSum += changedInputs[
                                                                  i] &&
                                                              checkedUsers[i]
                                                          ? num.parse(
                                                              toBePaidControllers[
                                                                      i]
                                                                  .text)
                                                          : 0;
                                                    }
                                                    print(changedSum);
                                                    if (changedSum >
                                                        num.parse(
                                                            amountController
                                                                .text)) {
                                                      TextEditingController
                                                          thisController =
                                                          toBePaidControllers[
                                                              groupUsers
                                                                  .indexOf(e)];
                                                      var diff = changedSum -
                                                          num.parse(
                                                              thisController
                                                                  .text);
                                                      thisController
                                                          .text = (num.parse(
                                                                  amountController
                                                                      .text) -
                                                              diff)
                                                          .floor()
                                                          .toString();
                                                    }
                                                    TextEditingController
                                                        thisController =
                                                        toBePaidControllers[
                                                            groupUsers
                                                                .indexOf(e)];
                                                    for (var i = 0;
                                                        i <
                                                            toBePaidControllers
                                                                .length;
                                                        i++) {
                                                      if (toBePaidControllers[
                                                                  i] !=
                                                              thisController &&
                                                          !changedInputs[i] &&
                                                          checkedUsers[i]) {
                                                        var numToDivide = 0;
                                                        for (var i = 0;
                                                            i <
                                                                changedInputs
                                                                    .length;
                                                            i++) {
                                                          if (!changedInputs[
                                                                  i] &&
                                                              checkedUsers[i]) {
                                                            numToDivide++;
                                                          }
                                                        }
                                                        toBePaidControllers[i]
                                                            .text = ((num.parse(
                                                                        amountController
                                                                            .text) -
                                                                    changedSum) /
                                                                numToDivide)
                                                            .clamp(
                                                                0,
                                                                num.parse(
                                                                    amountController
                                                                        .text))
                                                            .floor()
                                                            .toString();
                                                      }
                                                    }
                                                  },
                                                  controller:
                                                      toBePaidControllers[
                                                          groupUsers
                                                              .indexOf(e)],
                                                  icon: Icons.abc,
                                                  noIcon: true,
                                                  noMargin: true,
                                                  hintText: "Ödenecek",
                                                  onlyNumber: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      color: const Color(0xff292A33),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Borcu herkese eşit böl",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          Checkbox(
                              activeColor: const Color(0xffDA2851),
                              value: true,
                              onChanged: (v) {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
