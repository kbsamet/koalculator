import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/login_page.dart';
import 'package:koalculator/screens/group_screens/add_debt.dart';

final db = FirebaseFirestore.instance;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> users = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //getUsers();
    //signUp();
  }

  void getUsers() async {
    await db.collection("users").get().then((value) {
      for (var user in value.docs) {
        print(user.data());
        db
            .collection("res")
            .doc(user.data()["resId"][0])
            .get()
            .then((value) => print(value.data()));
      }
    });
  }

  void signUp() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "kbayraktarsamet@gmail.com",
        password: "Samet123",
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null
        ? const LoginScreen()
        : const AddDebtScreen();
  }
}
