import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String text;
  final Color color;
  const Header({Key? key, required this.text, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
    );
  }
}
