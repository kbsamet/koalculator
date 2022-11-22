class Group {
  final String id;
  final List<String> users;

  Group(this.users, {required this.id});

  Group.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        users = json["users"];
}
