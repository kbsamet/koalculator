import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;
Future<KoalUser?> getUser(id) async {
  var res = await db.collection("users").doc(id).get();
  if (res.data() == null) return null;
  return KoalUser.fromJson(res.data()!);
}

Future<List<KoalUser>?> getUsers(List<dynamic> users) async {
  List<KoalUser> newUsers = [];
  for (var element in users) {
    var res = await db.collection("users").doc(element).get();

    newUsers.add(KoalUser.fromJson(res.data()!));
  }
  return newUsers;
}
