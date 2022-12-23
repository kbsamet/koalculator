class Group {
  final String? pic;
  final List<dynamic> users;
  final List<dynamic> userNames;
  final String name;
  String? id = "";

  Group(this.users, this.name, this.pic, this.userNames);

  Group.fromJson(Map<String, dynamic> json)
      : users = json["users"],
        name = json["name"],
        pic = json["pic"],
        userNames = json["userNames"];
}
