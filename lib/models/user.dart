class KoalUser {
  final String name;
  final Map<String, dynamic>? debts;
  final Map<String, dynamic>? friends;
  String? id = "";
  KoalUser(this.name, this.debts, this.friends);

  KoalUser.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        debts = json["debts"] == null
            ? null
            : json["debts"] as Map<String, dynamic>,
        friends = json["friends"] == null
            ? null
            : json["friends"] as Map<String, dynamic>;
}
