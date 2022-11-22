import 'package:flutter/material.dart';

class DebtButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPositive;
  const DebtButton(
      {Key? key, required this.onPressed, required this.isPositive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: isPositive
                  ? [const Color(0xff1A4D2E), const Color(0xff34A753)]
                  : [const Color(0xffF0055D), const Color(0xffFF3737)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: Text(
          isPositive ? "Dürt" : "Öde",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: "QuickSand"),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
