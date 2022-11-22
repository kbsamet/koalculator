import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/login_page.dart';

import '../../components/default_button.dart';
import '../../components/default_text_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void Signup() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+90${emailController.text}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    /*
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChooseNameScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }

      print(e.code);
    }
    */
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
                    height: 46,
                  ),
                  DefaultTextInput(
                    controller: emailController,
                    icon: Icons.mail_outline,
                    hintText: "E-mail",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DefaultTextInput(
                    controller: passwordController,
                    icon: Icons.key_outlined,
                    hintText: "Password",
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 46,
                  ),
                  DefaultButton(onPressed: Signup, text: "Üye Ol"),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hesabın var mı?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen())),
                        child: const Text(
                          "  Giriş Yap",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffFF3737)),
                        ),
                      )
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
