import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/utils/firestore_error_util.dart';
import '../base/chat_model.dart';
import '../util/chat_utils.dart';

class ChatService {
  final FirestoreErrorUtil _firestoreErrorUtil;
  ChatService({
    required FirestoreErrorUtil firestoreErrorUtil,
  }) : _firestoreErrorUtil = firestoreErrorUtil;

  Either<String, bool> createChat(
      {required String userId, required String chatId}) {
    try {
      ChatUtil.chats(userId).doc(chatId).set({
        "chatId": chatId,
      }, SetOptions(merge: true));

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Chat>>> streamChats(String userId) {
    return ChatUtil.chats(userId)
        .snapshots()
        .asyncMap<Either<String, List<Chat>>>(
      (querySnapshot) async {
        final chats = querySnapshot.docs.map((doc) {
          return Chat.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        return Right(chats);
      },
    ).handleError(
      (error) {
        final message = _firestoreErrorUtil.handleException(error);
        return Left("Error subscribing to chats: $message");
      },
    );
  }
}
