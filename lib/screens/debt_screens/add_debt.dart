import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:koalculator/components/debts/custom_showcase.dart';
import 'package:koalculator/components/debts/paid_box.dart';
import 'package:koalculator/components/debts/to_pay_box.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/groups.dart';
import 'package:koalculator/services/users.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';
import '../../models/debt.dart';
import '../../models/group.dart';
import '../../services/debts.dart';
import '../dashboard.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({Key? key}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  BannerAd? banner;
  final keyOne = GlobalKey();
  final keyTwo = GlobalKey();

  List<GlobalKey> groupKeysToPay = [];
  List<GlobalKey> groupKeysPaid = [];

  List<Group> groups = [];
  List<KoalUser> groupUsers = [];
  List<bool> checkedUsers = [];

  List<TextEditingController> paidControllers = [];
  List<TextEditingController> toBePaidControllers = [];
  List<bool> changedInputs = [];

  String selectedValue = "";
  TextEditingController amountController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;
  InterstitialAd? interstitial;

  @override
  void initState() {
    super.initState();
    initGroups();
    loadInterstitialAd();
  }

  void loadInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: 'ca-app-pub-1382789323352838/8224723387',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print(ad);
            setState(() {
              interstitial = ad;
            });
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('$ad onAdDismissedFullScreenContent.');
                ad.dispose();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: ((context) => const Dashboard())),
                    (route) => false);
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void initGroups() async {
    try {
      List<Group> newGroups = await getGroups();
      setState(() {
        groups = newGroups;
        selectedValue = newGroups[0].name;
        getGroupUsers(newGroups[0]);
      });
    } catch (e) {}
  }

  void onAmountChanged(String s) {
    if (s == "") return;
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
    setState(() {
      isLoading = true;
    });
    num totalPaid = 0;
    for (var i = 0; i < paidControllers.length; i++) {
      if (checkedUsers[i]) {
        totalPaid += paidControllers[i].text == ""
            ? 0
            : num.parse(paidControllers[i].text);
      }
    }

    if (amountController.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tutar boş bıraklımaz")));
      setState(() {
        isLoading = false;
      });
      return;
    }

    if ((totalPaid - num.parse(amountController.text)).abs() >
        groupUsers.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Toplam ödenen ${amountController.text} e eşit değil")));

      setState(() {
        isLoading = false;
      });
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
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (descriptionController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Açıklama boş bıraklımaz")));
      setState(() {
        isLoading = false;
      });
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
          descriptionController.text,
          toPay.entries.first.value.abs(),
        );
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
          descriptionController.text,
          toPay.entries.first.value.abs(),
        );

        createDebt(debt);
        toPay[toPay.entries.first.key] =
            toPay.entries.first.value + toBePaid.entries.first.value;
        toBePaid.remove(toBePaid.entries.first.key);
      }
    }

    if (interstitial != null) {
      interstitial!.show();
    } else {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: ((context) => const Dashboard())),
          (route) => false);
    }
    print(interstitial);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  getGroupUsers(Group g) async {
    List<KoalUser> newUsers = [];
    List<TextEditingController> newPaidControllers = [];
    List<TextEditingController> newToBePaidControllers = [];
    List<bool> newChangedInputs = [];
    List<GlobalKey> newGroupKeysToPay = [];
    List<GlobalKey> newGroupKeysPaid = [];

    List<bool> newCheckedUsers = [];
    for (var i = 0; i < g.users.length; i++) {
      if (checkedUsers.length > i && !checkedUsers[i]) continue;
      var res = await getUsersWithElement(g.users[i]);
      KoalUser user = KoalUser.fromJson(res.data()!);
      user.id = g.users[i];
      newUsers.add(user);
      newPaidControllers.add(TextEditingController());
      newToBePaidControllers.add(TextEditingController());
      newChangedInputs.add(false);
      newCheckedUsers.add(true);
      if (i < 3) {
        newGroupKeysToPay.add(GlobalKey());
        newGroupKeysPaid.add(GlobalKey());
      }
    }
    if (!(await hasSeenTutorial())) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase(
            [keyOne, keyTwo, ...groupKeysPaid, ...groupKeysToPay]);
      });
    }

    print([keyOne, keyTwo, ...groupKeysPaid, ...groupKeysToPay]);
    setState(() {
      groupUsers = newUsers;
      paidControllers = newPaidControllers;
      toBePaidControllers = newToBePaidControllers;
      changedInputs = newChangedInputs;
      checkedUsers = newCheckedUsers;
      groupKeysPaid = newGroupKeysPaid;
      groupKeysToPay = newGroupKeysToPay;
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
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    const Text(
                      "Borç Ekle",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffF71B4E)),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outlined,
                        size: 25,
                        color: Color(0xffF71B4E),
                      ),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShowCaseWidget.of(context).startShowCase([
                            keyOne,
                            keyTwo,
                            ...groupKeysPaid,
                            ...groupKeysToPay
                          ]);
                        });
                      },
                    )
                  ],
                ),
              ),
              body: Container(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    banner != null
                        ? Container(
                            width: banner!.size.width.toDouble(),
                            height: banner!.size.height.toDouble(),
                            alignment: Alignment.center,
                            child: AdWidget(ad: banner!),
                          )
                        : Container(),
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
                          items: groups.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            );
                          }).toList(),
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
                          child: CustomShowcaseWidget(
                            globalKey: keyOne,
                            description:
                                "Buraya oluşturacağınız borcun açıklamasını giriniz (örn. Pizza)",
                            child: DefaultTextInput(
                                noMargin: true,
                                noIcon: true,
                                hintText: "Açıklama",
                                controller: descriptionController,
                                icon: Icons.announcement_rounded),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: CustomShowcaseWidget(
                            globalKey: keyTwo,
                            description:
                                "Buraya oluşturacağınız borcun toplam tutarını giriniz (örn 200₺)",
                            child: DefaultTextInput(
                                onChanged: onAmountChanged,
                                noIcon: true,
                                onlyNumber: true,
                                hintText: "Miktar",
                                noMargin: true,
                                controller: amountController,
                                icon: Icons.monetization_on),
                          ),
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
                                                      onAmountChanged(
                                                          amountController
                                                              .text);
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
                                              PaidBox(
                                                  e: e,
                                                  groupUsers: groupUsers,
                                                  groupKeysPaid: groupKeysPaid,
                                                  paidControllers:
                                                      paidControllers,
                                                  checkedUsers: checkedUsers),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              ToPayBox(
                                                  e: e,
                                                  groupUsers: groupUsers,
                                                  groupKeysToPay:
                                                      groupKeysToPay,
                                                  toBePaidControllers:
                                                      toBePaidControllers,
                                                  checkedUsers: checkedUsers,
                                                  amountController:
                                                      amountController,
                                                  changedInputs: changedInputs,
                                                  setState: setState)
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
                    const SizedBox(height: 5),
                    DefaultButton(
                      onPressed: addDebt,
                      text: "Borç Ekle",
                      isLoading: isLoading,
                    )
                  ],
                ),
              ),
            ));
  }
}
