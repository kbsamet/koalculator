import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/choose_name.dart';
import 'package:koalculator/screens/auth_screens/login_page.dart';
import 'package:koalculator/screens/dashboard.dart';
import 'package:koalculator/services/users.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

final db = FirebaseFirestore.instance;

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final bool delete;
  const OtpPage({Key? key, required this.phoneNumber, this.delete = false})
      : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool isLoading = false;
  String? verificationId;
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Login();
  }

  void Login() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+90${widget.phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          isLoading = false;
        });
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
    setState(() {
      isLoading = true;
    });
    try {
      PhoneAuthCredential credential =
          verifyAccount(verificationId!, codeController.text);

      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (FirebaseAuth.instance.currentUser != null) {
        if (widget.delete) {
          await FirebaseAuth.instance.currentUser!.delete();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hesabınız silindi.")));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: ((context) => const LoginScreen())),
              (route) => false);
        }

        var token = await FirebaseMessaging.instance.getToken();
        db.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set(
            {"phoneNumber": widget.phoneNumber, "token": token},
            SetOptions(merge: true));

        var user = await getAllUsersById();
        if (user.data()!["name"] == null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: ((context) => const ChooseNameScreen())),
              (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: ((context) => const Dashboard())),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Girdiğiniz şifre yanlış")));

      setState(() {
        isLoading = false;
        print(isLoading);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1B1C26),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 5),
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
                  SizedBox(
                    width: double.infinity,
                    child: DefaultTextInput(
                      onlyNumber: true,
                      controller: codeController,
                      icon: Icons.password,
                      hintText: "Tek Kullanımlık Şifre",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: DefaultButton(
                        onPressed: Verify,
                        text: "Devam Et",
                        isLoading: isLoading,
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: Login,
                    child: const Text(
                      "Tekrar şifre gönder",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
