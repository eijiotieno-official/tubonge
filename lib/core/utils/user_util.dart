import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserUtil {
  static String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  static final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
}
