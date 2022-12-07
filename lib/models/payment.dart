import 'package:koalculator/models/user.dart';

class Payment {
  num amount;
  final String groupId;
  final String recieverId;
  final String senderId;
  String? id;
  KoalUser? reciever;
  KoalUser? sender;

  Payment(this.amount, this.groupId, this.recieverId, this.senderId);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'groupId': groupId,
        'recieverId': recieverId,
        'senderId': senderId,
      };

  Payment.fromJson(Map<String, dynamic> json)
      : amount = json["amount"],
        groupId = json["groupId"],
        recieverId = json["recieverId"],
        senderId = json["senderId"];
}
