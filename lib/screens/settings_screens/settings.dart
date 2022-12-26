import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/components/empty_button.dart';
import 'package:koalculator/components/groups/group_profile_friend_view.dart';
import 'package:koalculator/components/header.dart';
import 'package:koalculator/screens/settings_screens/privacy_policy.dart';

import '../../components/default_button.dart';
import '../../models/user.dart';
import '../../services/users.dart';
import '../main_page.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  KoalUser? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUser();
  }

  void initUser() async {
    KoalUser? user_ = await getUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      user = user_!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1B1C26),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1B1C26),
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 30, color: Color(0xffF71B4E)),
              onPressed: () => Navigator.of(context).pop()),
          title: const Text(
            "Ayarlar",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color(0xffF71B4E)),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            user == null
                ? const CircularProgressIndicator(
                    color: Color(0xffF71B4E),
                  )
                : GroupProfileFriendView(
                    user: user!,
                  ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy())),
              child: Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  color: const Color(0xff292A33),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Header(text: "Gizlilik Politikası")),
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainPage()));
              },
              child: Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  color: const Color(0xff292A33),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Header(text: "Çıkış Yap")),
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        contentPadding: const EdgeInsets.all(30),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        backgroundColor: const Color(0xff1B1C26),
                        title: const Header(
                            text:
                                'Hesabınızı Silmek İstediğinize Emin Misiniz?'),
                        content: SizedBox(
                          width: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 120,
                                    child: EmptyButton(
                                      text: 'İptal',
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 100,
                                    child: DefaultButton(
                                      text: 'Sil',
                                      onPressed: () => deleteAccount(context),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
              child: Container(
                  width: double.infinity,
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  color: const Color(0xff292A33),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Header(
                          text: "Hesabını Sil",
                          color: Color(0xffF71B4E),
                        )),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
