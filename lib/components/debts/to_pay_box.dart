import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koalculator/components/debts/custom_showcase.dart';

import '../../models/user.dart';
import '../default_text_input.dart';

class ToPayBox extends StatelessWidget {
  final KoalUser e;
  final List<KoalUser> groupUsers;
  final List<GlobalKey> groupKeysToPay;
  final List<TextEditingController> toBePaidControllers;
  final List<bool> checkedUsers;
  final TextEditingController amountController;
  final List<bool> changedInputs;
  final Function setState;

  const ToPayBox(
      {super.key,
      required this.e,
      required this.groupUsers,
      required this.groupKeysToPay,
      required this.toBePaidControllers,
      required this.checkedUsers,
      required this.amountController,
      required this.changedInputs,
      required this.setState});

  @override
  Widget build(BuildContext context) {
    String payAmount = (200 / min(groupUsers.length, 3)).floor().toString();
    return SizedBox(
      width: 100,
      child: CustomShowcaseWidget(
        globalKey: groupKeysToPay.length > groupUsers.indexOf(e)
            ? groupKeysToPay[groupUsers.indexOf(e)]
            : null,
        description:
            "Buraya ${e.name} 'nın ödemesi gere borç miktarını giriniz. (örn. ${e.name} $payAmount₺ lik pizza yediği için $payAmount₺ )",
        child: DefaultTextInput(
          isDisabled: !checkedUsers[groupUsers.indexOf(e)],
          onChanged: (s) {
            print(checkedUsers);
            setState(() {
              changedInputs[groupUsers.indexOf(e)] = true;
              if (s == "") {
                changedInputs[groupUsers.indexOf(e)] = false;
              }
            });
            num changedSum = 0;
            for (var i = 0; i < changedInputs.length; i++) {
              changedSum += changedInputs[i] && checkedUsers[i]
                  ? num.parse(toBePaidControllers[i].text)
                  : 0;
            }
            print(changedSum);
            if (changedSum > num.parse(amountController.text)) {
              TextEditingController thisController =
                  toBePaidControllers[groupUsers.indexOf(e)];
              var diff = changedSum - num.parse(thisController.text);
              thisController.text =
                  (num.parse(amountController.text) - diff).floor().toString();
            }
            TextEditingController thisController =
                toBePaidControllers[groupUsers.indexOf(e)];
            for (var i = 0; i < toBePaidControllers.length; i++) {
              if (toBePaidControllers[i] != thisController &&
                  !changedInputs[i] &&
                  checkedUsers[i]) {
                var numToDivide = 0;
                for (var i = 0; i < changedInputs.length; i++) {
                  if (!changedInputs[i] && checkedUsers[i]) {
                    numToDivide++;
                  }
                }
                toBePaidControllers[i].text =
                    ((num.parse(amountController.text) - changedSum) /
                            numToDivide)
                        .clamp(0, num.parse(amountController.text))
                        .floor()
                        .toString();
              }
            }
          },
          controller: toBePaidControllers[groupUsers.indexOf(e)],
          icon: Icons.abc,
          noIcon: true,
          noMargin: true,
          hintText: "Ödenecek",
          onlyNumber: true,
        ),
      ),
    );
  }
}
