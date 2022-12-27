import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  const DefaultButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? () {} : onPressed,
      child: Container(
        height: 53,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xffFD4365), Color(0xffFD2064)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        child: isLoading
            ? Container(
                padding: const EdgeInsets.all(2),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: "QuickSand"),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
