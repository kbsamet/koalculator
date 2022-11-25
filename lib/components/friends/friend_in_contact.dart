import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/friends.dart';

class FriendInContact extends StatefulWidget {
  final KoalUser user;
  final Contact? contact;
  final bool isSent;
  const FriendInContact(
      {Key? key, required this.user, this.contact, this.isSent = false})
      : super(key: key);

  @override
  State<FriendInContact> createState() => _FriendInContactState();
}

class _FriendInContactState extends State<FriendInContact> {
  bool isSent = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isSent = widget.isSent;
    });
  }

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
                width: 20,
              ),
              isSent
                  ? Text(
                      widget.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  : Column(
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
                          widget.contact!.displayName!,
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
              onTap: () {
                if (isSent) return;
                sendFriendRequest(widget.user.id!);
                setState(() {
                  isSent = true;
                });
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isSent
                          ? [const Color(0xff0F1120), const Color(0xff0F1120)]
                          : [const Color(0xffFD4365), const Color(0xffFD2064)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Text(
                  isSent ? "İstek Gönderildi" : "Arkadaş Ekle",
                  style: const TextStyle(
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
