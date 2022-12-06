import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/config/adConfig.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/groups.dart';

import '../../models/debt.dart';
import '../../models/group.dart';
import '../../services/debts.dart';
import '../dashboard.dart';

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
    showAd();
    initGroups();
  }

  void initGroups() async {
    List<Group> newGroups = await getGroups();
    setState(() {
      groups = newGroups;
      selectedValue = newGroups[0].name;
      getGroupUsers(newGroups[0]);
    });
  }

  void onAmountChanged(String s) {
    num amount = num.parse(s);

    num numOfChecked = 0;

    for (var element in checkedUsers) {
      numOfChecked += element == true ? 1 : 0;
    }

    for (var i = 0; i < toBePaidControllers.length; i++) {
      if (checkedUsers[i]) {
        toBePaidControllers[i].text =
            (amount / numOfChecked).floor().toString();
      }
    }

    setState(() {
      changedInputs = List.filled(toBePaidControllers.length, false);
    });
  }

  void addDebt() async {
    num totalPaid = 0;
    for (var i = 0; i < paidControllers.length; i++) {
      if (checkedUsers[i]) {
        totalPaid += paidControllers[i].text == ""
            ? 0
            : num.parse(paidControllers[i].text);
      }
    }
    if ((totalPaid - num.parse(amountController.text)).abs() >
        groupUsers.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Toplam ödenen ${amountController.text} e eşit değil")));
      return;
    }

    totalPaid = 0;
    for (var i = 0; i < toBePaidControllers.length; i++) {
      if (checkedUsers[i]) {
        totalPaid += toBePaidControllers[i].text == ""
            ? 0
            : num.parse(toBePaidControllers[i].text);
      }
    }
    if ((totalPaid - num.parse(amountController.text)).abs() >
        groupUsers.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Toplam ödenecek ${amountController.text} e eşit değil")));
      return;
    }
    if (descriptionController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Açıklama boş bıraklımaz")));
      return;
    }

    Map<int, num> toBePaid = {};
    Map<int, num> toPay = {};

    for (var i = 0; i < toBePaidControllers.length; i++) {
      if (checkedUsers[i]) {
        num paidVal = paidControllers[i].text == ""
            ? 0
            : num.parse(paidControllers[i].text);
        num toBePaidVal = toBePaidControllers[i].text == ""
            ? 0
            : num.parse(toBePaidControllers[i].text);
        var diff = paidVal - toBePaidVal;
        if (diff > 0) {
          toBePaid.addAll({i: diff});
        } else if (diff < 0) {
          toPay.addAll({i: diff});
        }
      }
    }
    toPay = Map.fromEntries(
        toPay.entries.toList()..sort((a, b) => a.value.compareTo(b.value)));
    toBePaid = Map.fromEntries(
        toBePaid.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    int i = 0;

    while (toPay.isNotEmpty) {
      i++;
      if (i > 100) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Bir hata oluştu")));
        break;
      }
      if (toPay.entries.first.value.abs() <= toBePaid.entries.first.value) {
        Debt debt = Debt(
            toPay.entries.first.value.abs(),
            groups.where((element) => element.name == selectedValue).first.id!,
            groupUsers[toBePaid.entries.first.key].id!,
            groupUsers[toPay.entries.first.key].id!,
            descriptionController.text);
        createDebt(debt);
        toBePaid[toBePaid.entries.first.key] =
            toBePaid.entries.first.value - toPay.entries.first.value.abs();
        toPay.remove(toPay.entries.first.key);
      } else {
        Debt debt = Debt(
            toBePaid.entries.first.value,
            groups.where((element) => element.name == selectedValue).first.id!,
            groupUsers[toBePaid.entries.first.key].id!,
            groupUsers[toPay.entries.first.key].id!,
            descriptionController.text);

        createDebt(debt);
        toPay[toPay.entries.first.key] =
            toPay.entries.first.value + toBePaid.entries.first.value;
        toBePaid.remove(toBePaid.entries.first.key);
      }
    }

    await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) => const Dashboard())),
        (route) => false);
    setState(() {});
  }

  getGroupUsers(Group g) async {
    List<KoalUser> newUsers = [];
    List<TextEditingController> newPaidControllers = [];
    List<TextEditingController> newToBePaidControllers = [];
    List<bool> newChangedInputs = [];

    List<bool> newCheckedUsers = [];
    for (var i = 0; i < g.users.length; i++) {
      if (checkedUsers.length > i && !checkedUsers[i]) continue;
      var res = await db.collection("users").doc(g.users[i]).get();
      KoalUser user = KoalUser.fromJson(res.data()!);
      user.id = g.users[i];
      newUsers.add(user);
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
                  onPressed: () =>
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const Dashboard(),
                  )),
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
                    const SizedBox(
                      height: 20,
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
                    const SizedBox(height: 5),
                    DefaultButton(onPressed: addDebt, text: "Borç Ekle")
                  ],
                ),
              ),
            ));
  }
}
