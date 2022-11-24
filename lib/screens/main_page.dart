import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/screens/auth_screens/login_page.dart';
import 'package:koalculator/screens/dashboard.dart';
import 'package:koalculator/screens/group_screens/add_debt.dart';
import 'package:koalculator/screens/profile_screens/profile_screen.dart';

final db = FirebaseFirestore.instance;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //getUsers();
    //signUp();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser == null
        ? const LoginScreen()
        : Dashboard();
  }
}
