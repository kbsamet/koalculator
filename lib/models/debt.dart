class Debt {
  final num amount;
  final String groupId;
  final String recieverId;
  final String senderId;

  Debt(this.amount, this.groupId, this.recieverId, this.senderId);

  Debt.fromJson(Map<String, dynamic> json)
      : amount = json["amount"],
        groupId = json["groupId"],
        recieverId = json["recieverId"],
        senderId = json["senderId"];
}
