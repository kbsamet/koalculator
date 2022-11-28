import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "Profil",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color(0xffF71B4E)),
              ),
            ),
            body: SizedBox(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        height: 150,
                        width: 150,
                        decoration: const BoxDecoration(
                            color: Color(0xff292A33), shape: BoxShape.circle),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: Color(0xffF71B4E),
                            size: 30,
                          ),
                        ),
                      ),
                      Container(
                        child: const Text(
                          "Emre Bakır",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Color.fromARGB(255, 255, 202, 214)),
                        ),
                      ),
                      Container(child: const Text("AKA KK Bakir")),
                      Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(right: 50, left: 50, top: 40),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // aşağıdaki 3 containeri tek hale nasıl getirebilirim ?? deliricem...
                              Container(
                                child: const Text(
                                  "Gruplar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color:
                                          Color.fromARGB(255, 255, 245, 247)),
                                ),
                              ),
                              const SizedBox(
                                  height: 160,
                                  child: VerticalDivider(color: Colors.red)),
                              Container(
                                child: const Text(
                                  "Arkadaşlar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                      color:
                                          Color.fromARGB(255, 255, 239, 242)),
                                ),
                              ),
                            ]),
                      )
                    ]))));
  }
}
