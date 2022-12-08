import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData icon;
  final bool isPassword;
  final bool noMargin;
  final bool noIcon;
  final bool onlyNumber;
  final bool isDisabled;
  final Function(String)? onChanged;

  const DefaultTextInput(
      {Key? key,
      required this.controller,
      this.hintText,
      required this.icon,
      this.isPassword = false,
      this.noMargin = false,
      this.noIcon = false,
      this.onlyNumber = false,
      this.isDisabled = false,
      this.onChanged})
      : super(key: key);

  @override
  State<DefaultTextInput> createState() => _DefaultTextInputState();
}

class _DefaultTextInputState extends State<DefaultTextInput> {
  bool isObscured = false;

  @override
  void initState() {
    super.initState();
    stateInit();
  }

  void stateInit() async {
    isObscured = widget.isPassword;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 54,
        width: double.infinity,
        margin: widget.noMargin
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
            border: Border.all(
                color: widget.isDisabled
                    ? const Color.fromARGB(255, 92, 92, 92)
                    : const Color(0xff949292)),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.noIcon
                ? Container()
                : Icon(
                    widget.icon,
                    size: 26,
                  ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                style: TextStyle(
                    color: widget.isDisabled
                        ? const Color.fromARGB(255, 92, 92, 92)
                        : Colors.white),
                enabled: !widget.isDisabled,
                onChanged: widget.onChanged ?? (e) => {},
                controller: widget.controller,
                obscureText: isObscured,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      color: widget.isDisabled
                          ? const Color.fromARGB(255, 92, 92, 92)
                          : Colors.white),
                  border: InputBorder.none,
                  hintText: widget.hintText ?? "",
                ),
                keyboardType: widget.onlyNumber
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: widget.onlyNumber
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ]
                    : [], // Only numbers can be entered
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
