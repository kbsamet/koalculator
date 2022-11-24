import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/screens/auth_screens/otp_page.dart';

import '../../components/default_text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();

  submitPhone() {
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = RegExp(pattern);
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen bir telefon numarası giriniz")));
      return;
    } else if (!regExp.hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Girdiğiniz telefon numarası doğru değil")));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OtpPage(phoneNumber: phoneController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1B1C26),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Koalculator",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    color: Color(0xffF71B4E),
                    indent: 30,
                    endIndent: 30,
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DefaultTextInput(
                    onlyNumber: true,
                    controller: phoneController,
                    icon: Icons.phone,
                    hintText: "Telefon Numaran",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: DefaultButton(
                          onPressed: submitPhone, text: "Devam Et")),
                  const SizedBox(
                    height: 30,
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
