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
  final int maxLines;
  final double height;
  final bool phoneNumber;
  final bool readOnly;

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
      this.height = 54,
      this.maxLines = 1,
      this.readOnly = false,
      this.phoneNumber = false,
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
        height: widget.height,
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
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
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
                    ? widget.phoneNumber
                        ? <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            _PhoneNumberFormatter(),
                            LengthLimitingTextInputFormatter(14)
                          ]
                        : <TextInputFormatter>[
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

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int selectionStart = newValue.selection.start;
    final int selectionEnd = newValue.selection.end;
    final String formattedPhoneNumber = formatPhoneNumber(newValue.text);
    return TextEditingValue(
      text: formattedPhoneNumber,
      selection: TextSelection.collapsed(offset: formattedPhoneNumber.length),
    );
  }
}

String formatPhoneNumber(String input) {
  if (input.length <= 3) {
    return input;
  } else if (input.length <= 6) {
    return '(${input.substring(0, 3)}) ${input.substring(3)}';
  } else {
    return '(${input.substring(0, 3)}) ${input.substring(3, 6)}-${input.substring(6)}';
  }
}
