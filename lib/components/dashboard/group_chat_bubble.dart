import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';

import '../../models/group.dart';

final List<Color> GroupNameColors = [
  Colors.white,
  Colors.amber,
  Colors.red,
  Colors.purple,
  Colors.green,
  Colors.orange,
  Colors.blue,
  Colors.pink,
  Colors.teal
];

class GroupChatBubble extends StatelessWidget {
  final String sender;
  final bool isSender;
  final String reciever;
  final num amount;
  final Group group;
  final String senderId;
  const GroupChatBubble(
      {Key? key,
      required this.sender,
      required this.isSender,
      required this.reciever,
      required this.amount,
      required this.group,
      required this.senderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      elevation: 0,
      backGroundColor: isSender
          ? const Color(0xffCE3C5E)
          : const Color.fromARGB(255, 50, 52, 61),
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      clipper: ChatBubbleClipper6(
          type: isSender ? BubbleType.sendBubble : BubbleType.receiverBubble),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: GroupNameColors[
                    group.users.indexOf(senderId) % GroupNameColors.length]),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "$reciever Kişisine $amount₺ Gönderdi",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
