import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';

import '../../models/group.dart';

final List<Color> GroupNameColors = [
  const Color.fromARGB(255, 247, 85, 73),
  Colors.green,
  Colors.orange,
  const Color.fromARGB(255, 221, 177, 45),
  const Color.fromARGB(255, 50, 199, 184),
  const Color.fromARGB(255, 225, 58, 255),
  Colors.pink,
];

class GroupChatBubble extends StatelessWidget {
  final String sender;
  final bool isSender;
  final String reciever;
  final num amount;
  final Group group;
  final String senderId;
  final String recieverId;

  const GroupChatBubble(
      {Key? key,
      required this.sender,
      required this.isSender,
      required this.reciever,
      required this.amount,
      required this.group,
      required this.senderId,
      required this.recieverId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      elevation: 0,
      // set the background color according to if the message is sent or received
      backGroundColor: isSender
          ? const Color.fromARGB(255, 96, 21, 46)
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reciever,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: GroupNameColors[group.users.indexOf(recieverId) %
                          GroupNameColors.length])),
              Text(
                " Kişisine $amount₺ Gönderdi",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
