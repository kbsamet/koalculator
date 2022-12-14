import 'package:cloud_firestore/cloud_firestore.dart';

class Debt {
  num amount;
  final String groupId;
  final String recieverId;
  final String senderId;
  final String description;
  // final String? createdAt;
  String? id;

  Debt(this.amount, this.groupId, this.recieverId, this.senderId,
      this.description);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'groupId': groupId,
        'recieverId': recieverId,
        'senderId': senderId,
        'description': description,
      };

  Debt.fromJson(Map<String, dynamic> json)
      : amount = json["amount"],
        groupId = json["groupId"],
        recieverId = json["recieverId"],
        description = json["description"],
        senderId = json["senderId"];
}
