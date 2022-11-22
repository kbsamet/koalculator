import 'package:flutter/material.dart';

import '../../screens/group_screens/group_detail_screen.dart';

class GroupListView extends StatelessWidget {
  final String groupName;
  final List<String> memberNames;
  const GroupListView(
      {Key? key, required this.groupName, required this.memberNames})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const GroupDetailScreen())),
      child: Container(
          color: const Color(0xff292A33),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/images/$groupName.jpg",
                  fit: BoxFit.fill,
                  width: 65,
                  height: 65,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      groupName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xffF71B4E)),
                    ),
                    /*
                    const Divider(
                      color: Color(0xffF71B4E),
                      thickness: 1.0,
                      endIndent: 30,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    */
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: memberNames.map((e) {
                        int i = memberNames.indexOf(e);
                        return i != memberNames.length - 1
                            ? Text(
                                "$e, ",
                                style: const TextStyle(fontSize: 15),
                              )
                            : Text(
                                e,
                                style: const TextStyle(fontSize: 15),
                              );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 6,
                    )
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 30,
                color: Color(0xffF71B4E),
              )
            ],
          )),
    );
  }
}
