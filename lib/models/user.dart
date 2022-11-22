class KoalUser {
  final String name;

  KoalUser(
    this.name,
  );

  KoalUser.fromJson(Map<String, dynamic> json) : name = json["name"];
}
