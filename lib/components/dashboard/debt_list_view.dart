import 'package:flutter/material.dart';
import 'package:koalculator/components/dashboard/debt_button.dart';

class DebtListView extends StatelessWidget {
  final String name;
  final num value;
  const DebtListView({Key? key, required this.name, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xff292A33),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  value > 0 ? "+ $value ₺" : "- ${-value} ₺",
                  style: TextStyle(
                      color: value > 0
                          ? const Color(0xff34A853)
                          : const Color(0xffF71B4E),
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                const SizedBox(
                  width: 20,
                ),
                DebtButton(onPressed: () {}, isPositive: value > 0),
                const SizedBox(
                  width: 20,
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 30,
                  color: Color(0xffF71B4E),
                )
              ],
            )
          ],
        ));
  }
}
