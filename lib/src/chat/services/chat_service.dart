import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../core/services/firestore_error_service.dart';
import '../models/chat_model.dart';
import '../utils/chat_utils.dart';

class ChatService {
  final FirestoreErrorService _firestoreErrorService;
  ChatService({
    required FirestoreErrorService firestoreErrorService,
  }) : _firestoreErrorService = firestoreErrorService;

  Either<String, bool> createChat(
      {required String userId, required String chatId}) {
    try {
      ChatUtils.chats(userId).doc(chatId).set({
        "chatId": chatId,
      }, SetOptions(merge: true));

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Chat>>> streamChats(String userId) {
    return ChatUtils.chats(userId)
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
        final message = _firestoreErrorService.handleException(error);
        return Left("Error subscribing to chats: $message");
      },
    );
  }
}
