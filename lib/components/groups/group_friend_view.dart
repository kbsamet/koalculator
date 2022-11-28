import 'package:flutter/material.dart';
import 'package:koalculator/models/user.dart';

class GroupFriendView extends StatefulWidget {
  final KoalUser user;
  final Function(KoalUser, bool) addUser;
  const GroupFriendView({Key? key, required this.user, required this.addUser})
      : super(key: key);

  @override
  State<GroupFriendView> createState() => _GroupFriendViewState();
}

class _GroupFriendViewState extends State<GroupFriendView> {
  bool checkboxValue = false;

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
                ],
              ),
            ],
          ),
          Checkbox(
            value: checkboxValue,
            onChanged: (e) {
              setState(() {
                checkboxValue = e!;
              });
              widget.addUser(widget.user, e!);
            },
            activeColor: const Color(0xffDA2851),
          )
        ],
      ),
    );
  }
}
