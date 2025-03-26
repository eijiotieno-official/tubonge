import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../core/services/firestore_error_service.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  CollectionReference _chats(String userId) => FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("chats");

  Either<String, bool> createChat(
      {required String userId, required String chatId}) {
    try {
      _chats(userId).doc(chatId).set({
        "chatId": chatId,
      });

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Chat>>> subscribeToChats(String userId) {
    return _chats(userId).snapshots().asyncMap<Either<String, List<Chat>>>(
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
