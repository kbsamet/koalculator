class KoalUser {
  final String name;
  final String bio;
  final Map<String, dynamic>? debts;
  final Map<String, dynamic>? friends;
  String? id = "";
  KoalUser(this.name, this.debts, this.friends, this.bio);

  KoalUser.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        debts = json["debts"] == null
            ? null
            : json["debts"] as Map<String, dynamic>,
        friends = json["friends"] == null
            ? null
            : json["friends"] as Map<String, dynamic>,
        bio = json["bio"] ?? "";
}
