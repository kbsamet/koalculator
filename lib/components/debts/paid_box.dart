import 'package:flutter/material.dart';
import 'package:koalculator/components/default_text_input.dart';
import 'package:koalculator/models/user.dart';

import 'custom_showcase.dart';

class PaidBox extends StatelessWidget {
  final KoalUser e;
  final List<KoalUser> groupUsers;
  final List<GlobalKey> groupKeysPaid;
  final List<TextEditingController> paidControllers;
  final List<bool> checkedUsers;

  const PaidBox(
      {super.key,
      required this.e,
      required this.groupUsers,
      required this.groupKeysPaid,
      required this.paidControllers,
      required this.checkedUsers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: CustomShowcaseWidget(
        globalKey: groupKeysPaid.length > groupUsers.indexOf(e)
            ? groupKeysPaid[groupUsers.indexOf(e)]
            : null,
        description:
            "Buraya ${e.name} 'nın toplam tutara katkısı${groupUsers.indexOf(e) == 0 ? " (örn. ${e.name} hesabı ödediği için 200₺)" : " (örn. ${e.name} hesaba katkı yapmadığı için 0₺)"}",
        child: DefaultTextInput(
          isDisabled: !checkedUsers[groupUsers.indexOf(e)],
          controller: paidControllers[groupUsers.indexOf(e)],
          icon: Icons.abc,
          noIcon: true,
          noMargin: true,
          hintText: "Ödenen",
          onlyNumber: true,
        ),
      ),
    );
  }
}
