import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../core/services/firestore_error_service.dart';
import '../models/message_model.dart';

class MessageService {
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  CollectionReference _chats(String userId) => FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("chats");

  CollectionReference _messages({
    required String userId,
    required String chatId,
  }) =>
      _chats(userId).doc(chatId).collection("messages");

  Either<String, Message> createMessage(Message message) {
    try {
      final docRef = _messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc();

      final updatedMessage = message.copyWith(
        sender: message.sender,
        id: docRef.id,
        status: message.receiver == message.sender
            ? MessageStatus.seen
            : MessageStatus.none,
      );

      docRef.set(updatedMessage.toMap());

      return Right(updatedMessage);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Either<String, bool> deleteMessage(Message message) {
    try {
      _messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc(message.id).delete();

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Either<String, bool> updateMessage(Message message) {
    try {
      _messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc(message.id).update(message.toMap());

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Message>>> subscribeToMessages({
    required String userId,
    required String chatId,
    required List<Message> initialMessages,
  }) {
    return _messages(userId: userId, chatId: chatId)
        .snapshots()
        .asyncMap<Either<String, List<Message>>>(
      (QuerySnapshot querySnapshot) {
        List<Message> messages = initialMessages;

        for (DocumentChange<Object?> change in querySnapshot.docChanges) {
          final subDocData = change.doc.data() as Map<String, dynamic>;
          switch (change.type) {
            case DocumentChangeType.added:
              final message = Message.fromMap(subDocData);
              if (!messages.any((element) => element.id == message.id)) {
                messages.add(message);
              }
              break;
            case DocumentChangeType.modified:
              final index = messages.indexWhere((m) => m.id == change.doc.id);
              if (index != -1) {
                messages[index] = Message.fromMap(subDocData);
              }
              break;
            case DocumentChangeType.removed:
              messages.removeWhere((m) => m.id == change.doc.id);
              break;
          }
        }

        return Right(messages);
      },
    ).handleError(
      (error) {
        final message = _firestoreErrorService.handleException(error);
        return Left("Error subscribing to chats: $message");
      },
    );
  }

  static List<Message> sortItemsByDate(
    List<Message> messages, {
    bool ascending = true,
  }) {
    if (messages.isEmpty) {
      return [];
    }

    messages.sort((a, b) => ascending
        ? a.timeSent.compareTo(b.timeSent)
        : b.timeSent.compareTo(a.timeSent));

    return messages;
  }
}
