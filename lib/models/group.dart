class Group {
  final String? pic;
  final List<dynamic> users;
  final String name;
  String? id = "";

  Group(this.users, this.name, this.pic);

  Group.fromJson(Map<String, dynamic> json)
      : users = json["users"],
        name = json["name"],
        pic = json["pic"];
}
