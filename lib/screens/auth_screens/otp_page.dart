import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/choose_name.dart';
import 'package:koalculator/screens/dashboard.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

final db = FirebaseFirestore.instance;

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String? verificationId;
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: codeController.text);

      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (FirebaseAuth.instance.currentUser != null) {
        db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({"phoneNumber": widget.phoneNumber}, SetOptions(merge: true));

        var user = await db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        print(user.data()!["name"]);
        if (user.data()!["name"] == null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: ((context) => const ChooseNameScreen())));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: ((context) => const Dashboard())));
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Girdiğiniz şifre yanlış")));
    }
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
                      hintText: "Tek Kullanımlık Şfire",
                    ),
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
