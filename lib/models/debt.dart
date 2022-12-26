class Debt {
  num amount;
  final num originalAmount;
  final String groupId;
  final String recieverId;
  final String senderId;
  final String description;
  DateTime? createdAt;
  String? id;

  Debt(this.amount, this.groupId, this.recieverId, this.senderId,
      this.description, this.originalAmount);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'originalAmount': originalAmount,
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
        senderId = json["senderId"],
        originalAmount = json["originalAmount"],
        createdAt =
            json["createdAt"] == null ? null : json["createdAt"].toDate();
}
