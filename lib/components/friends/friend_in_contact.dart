import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';

class FriendInContact extends StatefulWidget {
  final KoalUser user;
  final Contact contact;
  const FriendInContact({Key? key, required this.user, required this.contact})
      : super(key: key);

  @override
  State<FriendInContact> createState() => _FriendInContactState();
}

class _FriendInContactState extends State<FriendInContact> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      color: const Color(0xff292A33),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  border: Border.all(color: Colors.black),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.contact.displayName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xffB0B0B0)),
                  )
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xffFD4365), Color(0xffFD2064)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: const Text(
                  "Arkadaş Ekle",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: "QuickSand"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
