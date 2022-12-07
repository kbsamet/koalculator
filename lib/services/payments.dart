import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment.dart';

final db = FirebaseFirestore.instance;

Future<List<Payment>> getPaymentsByGroupId(groupId) async {
  var res = await db.collection("groups").doc(groupId).get();
  var data = res.data()!["payments"];
  if (data == null) {
    return [];
  }
  List<Payment> payments = [];
  for (var element in data) {
    var payment = await getPaymentDetails(element.toString());
    payment.id = element;
    payments.add(payment);
  }
  return payments;
}

Future<Payment> getPaymentDetails(String id) async {
  var value = await db.collection("payments").doc(id).get();
  Payment payment = Payment.fromJson(value.data()!);
  return payment;
}
