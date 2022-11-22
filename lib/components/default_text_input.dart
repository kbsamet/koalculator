import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DefaultTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData icon;
  final bool isPassword;
  const DefaultTextInput(
      {Key? key,
      required this.controller,
      this.hintText,
      required this.icon,
      this.isPassword = false})
      : super(key: key);

  @override
  State<DefaultTextInput> createState() => _DefaultTextInputState();
}

class _DefaultTextInputState extends State<DefaultTextInput> {
  bool isObscured = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      isObscured = widget.isPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
            border: SchedulerBinding
                        .instance.platformDispatcher.platformBrightness ==
                    Brightness.light
                ? Border.all(color: const Color(0xff949292))
                : Border.all(color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 26,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                obscureText: isObscured,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText ?? "",
                ),
              ),
            ),
            widget.isPassword
                ? InkWell(
                    onTap: () => setState(() {
                      isObscured = !isObscured;
                    }),
                    child: Icon(isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  )
                : Container(),
          ],
        ));
  }
}
