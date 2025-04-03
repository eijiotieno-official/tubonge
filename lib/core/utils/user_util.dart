import 'package:cloud_firestore/cloud_firestore.dart';

class UserUtil {
  static final CollectionReference users =
      FirebaseFirestore.instance.collection("users");
}
