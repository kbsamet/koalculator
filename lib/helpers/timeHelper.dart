import 'package:cloud_firestore/cloud_firestore.dart';

FieldValue calculateTime() {
  return FieldValue.serverTimestamp();
}
