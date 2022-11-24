import 'package:flutter/material.dart';

class GroupFriendView extends StatelessWidget {
  const GroupFriendView({Key? key}) : super(key: key);

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
                children: const [
                  Text(
                    "Kelto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Rapist",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Color(0xffB0B0B0)),
                  )
                ],
              ),
            ],
          ),
          Checkbox(
            value: true,
            onChanged: (e) {},
            activeColor: const Color(0xffDA2851),
          )
        ],
      ),
    );
  }
}
