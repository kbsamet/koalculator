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
  List<TextEditingController> paidControllers = [];
  List<TextEditingController> toBePaidControllers = [];
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
      element.text = (amount / toBePaidControllers.length).toString();
    }
  }

  getGroupUsers(Group g) async {
    List<KoalUser> newUsers = [];
    List<TextEditingController> newPaidControllers = [];
    List<TextEditingController> newToBePaidControllers = [];

    for (var element in g.users) {
      var res = await db.collection("users").doc(element).get();
      newUsers.add(KoalUser.fromJson(res.data()!));
      newPaidControllers.add(TextEditingController());
      newToBePaidControllers.add(TextEditingController());
    }

    setState(() {
      groupUsers = newUsers;
      paidControllers = newPaidControllers;
      toBePaidControllers = newToBePaidControllers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedValue == ""
        ? Container()
        : Container(
            color: const Color(0xff303139),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Borç Ekle"),
              ),
              body: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Column(
                      children: groupUsers
                          .map((e) => Container(
                                padding: const EdgeInsets.all(20),
                                color: const Color(0xff292A33),
                                child: Row(
                                  children: [
                                    Text(
                                      e.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Checkbox(
                                        activeColor: const Color(0xffDA2851),
                                        value: true,
                                        onChanged: (e) {}),
                                    Flexible(
                                      child: DefaultTextInput(
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
                                    Flexible(
                                      child: DefaultTextInput(
                                        onChanged: (s) {
                                          if (num.parse(s) >
                                              num.parse(
                                                  amountController.text)) {
                                            TextEditingController
                                                thisController =
                                                toBePaidControllers[
                                                    groupUsers.indexOf(e)];
                                            thisController.text =
                                                amountController.text;
                                          }
                                          TextEditingController thisController =
                                              toBePaidControllers[
                                                  groupUsers.indexOf(e)];
                                          for (var element
                                              in toBePaidControllers) {
                                            if (element != thisController) {
                                              print((num.parse(
                                                      amountController.text) -
                                                  num.parse(
                                                      thisController.text)));
                                              print(toBePaidControllers.length -
                                                  1);
                                              print(((num.parse(amountController
                                                                  .text) -
                                                              num.parse(
                                                                  thisController
                                                                      .text)) /
                                                          toBePaidControllers
                                                              .length -
                                                      1)
                                                  .toString());
                                              element.text = ((num.parse(
                                                              amountController
                                                                  .text) -
                                                          num.parse(
                                                              thisController
                                                                  .text)) /
                                                      (toBePaidControllers
                                                              .length -
                                                          1))
                                                  .toString();
                                            }
                                          }
                                        },
                                        controller: toBePaidControllers[
                                            groupUsers.indexOf(e)],
                                        icon: Icons.abc,
                                        noIcon: true,
                                        noMargin: true,
                                        hintText: "Ödenecek",
                                        onlyNumber: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    )
                  ],
                ),
              ),
            ));
  }
}
