import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:koalculator/models/group.dart';
import 'package:koalculator/models/user.dart';
import 'package:koalculator/services/images.dart';
import '../../services/users.dart';

import '../../screens/group_screens/group_detail_screen.dart';

class GroupListView extends StatefulWidget {
  final Group group;
  const GroupListView({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupListView> createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  List<KoalUser> users = [];
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    stateInit();
  }

  void stateInit() async {
    imageUrl = await getGroupPic(widget.group.id);
    users = (await getUsers(widget.group.users))!;
    setState(() {});
  }

  // @override
  // void didUpdateWidget(covariant GroupListView oldWidget) {
  //   // TODO: implement didUpdateWidget
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.group != widget.group) {
  //     getImage();
  //     getUserNames();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GroupDetailScreen(
                group: widget.group,
              ))),
      child: Container(
          color: const Color(0xff292A33),
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: imageUrl == null
                    ? Image.asset(
                        "assets/images/group.png",
                        fit: BoxFit.fill,
                        width: 65,
                        height: 65,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl!,
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
                      widget.group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xffF71B4E)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                        children: users
                                .getRange(0, min(5, widget.group.users.length))
                                .map((e) {
                              int i = users.indexOf(e);
                              return i != min(4, widget.group.users.length - 1)
                                  ? Text(
                                      "${e.name},",
                                      style: const TextStyle(fontSize: 15),
                                    )
                                  : Text(
                                      e.name,
                                      style: const TextStyle(fontSize: 15),
                                    );
                            }).toList() +
                            [
                              Text(
                                widget.group.users.length > 5 ? "..." : "",
                                style: const TextStyle(fontSize: 15),
                              )
                            ]),
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
