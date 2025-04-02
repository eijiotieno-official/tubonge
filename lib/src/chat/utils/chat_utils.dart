import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUtils {
  static CollectionReference chats(String userId) => FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("chats");

  static CollectionReference messages({
    required String userId,
    required String chatId,
  }) =>
      chats(userId).doc(chatId).collection("messages");
}
