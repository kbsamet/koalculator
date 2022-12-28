import 'package:flutter/material.dart';
import 'package:koalculator/components/default_button.dart';
import 'package:koalculator/screens/auth_screens/otp_page.dart';

import '../../components/default_text_input.dart';
import "package:url_launcher/url_launcher.dart";

class LoginScreen extends StatefulWidget {
  final bool delete;
  const LoginScreen({Key? key, this.delete = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  bool isAccepted = false;

  submitPhone() {
    if (!isAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Koalculator'ın Gizlilik Şartları'nı kabul etmelisiniz")));
      return;
    }
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    String phoneNumber = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    RegExp regExp = RegExp(pattern);
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen bir telefon numarası giriniz")));
      return;
    } else if (!regExp.hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Girdiğiniz telefon numarası doğru değil")));
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            OtpPage(phoneNumber: phoneNumber, delete: widget.delete)));
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
                    phoneNumber: true,
                    controller: phoneController,
                    icon: Icons.phone,
                    hintText: "Telefon Numaran",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Checkbox(
                          activeColor: const Color(0xffDA2851),
                          value: isAccepted,
                          onChanged: (value) => setState(() {
                                isAccepted = value!;
                              })),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Koalculator'ın ",
                                  style: TextStyle(color: Colors.white)),
                              InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse(
                                        "https://pages.flycricket.io/koalculator/privacy.html"));
                                  },
                                  child: const Text(
                                    "Gizlilik Şartları",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              const Text("'nı okudum "),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [Text("ve kabul ediyorum.")],
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: DefaultButton(
                        onPressed: submitPhone,
                        text: "Devam Et",
                      )),
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
