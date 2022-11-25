import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koalculator/models/user.dart';

final db = FirebaseFirestore.instance;
Future<KoalUser?> getUser(id) async {
  var res = await db.collection("users").doc(id).get();
  if (res.data() == null) return null;
  return KoalUser.fromJson(res.data()!);
}
