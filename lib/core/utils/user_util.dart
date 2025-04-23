import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for accessing Firestore user collection
class UserUtil {
  /// Reference to the 'users' collection in Firestore
  static final CollectionReference users =
      FirebaseFirestore.instance.collection("users");
}
