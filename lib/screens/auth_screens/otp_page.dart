import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koalculator/screens/main_page.dart';

import '../../components/default_button.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String? verificationId;
  List<TextEditingController> codeControllers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var i = 0; i < 6; i++) {
      codeControllers.add(TextEditingController());
    }
    Login();
  }

  void Login() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+90${widget.phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Girdiğiniz şifre yanlış")));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void Verify() async {
    String code = "";
    for (var controller in codeControllers) {
      code += controller.text;
    }
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: code);

    // Sign the user in (or link) with the credential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const MainPage())));
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _textFieldOTP(
                          first: true,
                          last: false,
                          controller: codeControllers[0]),
                      const SizedBox(
                        width: 5,
                      ),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: codeControllers[1]),
                      const SizedBox(
                        width: 5,
                      ),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: codeControllers[2]),
                      const SizedBox(
                        width: 5,
                      ),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: codeControllers[3]),
                      const SizedBox(
                        width: 5,
                      ),
                      _textFieldOTP(
                          first: false,
                          last: false,
                          controller: codeControllers[4]),
                      const SizedBox(
                        width: 5,
                      ),
                      _textFieldOTP(
                          first: false,
                          last: true,
                          controller: codeControllers[5]),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child:
                          DefaultButton(onPressed: Verify, text: "Devam Et")),
                  const SizedBox(
                    height: 30,
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _textFieldOTP(
      {required bool first, last, required TextEditingController controller}) {
    return SizedBox(
      height: 60,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          child: TextField(
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            autofocus: true,
            onChanged: (value) {
              if (value.length == 1 && last == false) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && first == false) {
                FocusScope.of(context).previousFocus();
              }
            },
            showCursor: false,
            readOnly: false,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counter: const Offstage(),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Color(0xffAFB0B6)),
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Color(0xffFF3737)),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
