class KoalUser {
  final String name;
  final Map<String, dynamic>? debts;

  KoalUser(this.name, this.debts);

  KoalUser.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        debts = json["debts"] == null
            ? null
            : json["debts"] as Map<String, dynamic>;
}
