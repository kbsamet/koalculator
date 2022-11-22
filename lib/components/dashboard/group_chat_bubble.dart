import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';

class GroupChatBubble extends StatelessWidget {
  final String sender;
  final bool isSender;
  final String reciever;
  final num amount;
  const GroupChatBubble(
      {Key? key,
      required this.sender,
      required this.isSender,
      required this.reciever,
      required this.amount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      elevation: 0,
      backGroundColor: const Color.fromARGB(255, 50, 52, 61),
      clipper: ChatBubbleClipper2(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "$reciever Kişisine $amount Gönderdi",
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
