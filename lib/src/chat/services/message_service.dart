import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/firestore_error_service.dart';
import '../models/message_model.dart';
import '../utils/chat_utils.dart';

class MessageService {
  final FirestoreErrorService _firestoreErrorService;
  MessageService({
    required FirestoreErrorService firestoreErrorService,
  }) : _firestoreErrorService = firestoreErrorService;

  final String? _currentUser = FirebaseAuth.instance.currentUser?.uid;

  Either<String, Message> createMessage(Message message) {
    try {
      if (_currentUser == null) {
        return Left("User not log in");
      }

      final DocumentReference<Object?> docRef = ChatUtils.messages(
        userId: _currentUser,
        chatId: message.receiver,
      ).doc();

      final Message updatedMessage = message.copyWith(
        sender: _currentUser,
        id: docRef.id,
        status: message.receiver == _currentUser
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
      ChatUtils.messages(
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
      ChatUtils.messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc(message.id).update(message.toMap());

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Message>>> streamMessages({
    required String userId,
    required String chatId,
    required List<Message> initialMessages,
  }) {
    return ChatUtils.messages(userId: userId, chatId: chatId)
        .snapshots()
        .asyncMap<Either<String, List<Message>>>(
      (QuerySnapshot querySnapshot) {
        List<Message> messages = initialMessages;

        for (DocumentChange<Object?> change in querySnapshot.docChanges) {
          final Map<String, dynamic> subDocData =
              change.doc.data() as Map<String, dynamic>;

          switch (change.type) {
            case DocumentChangeType.added:
              final Message message = Message.fromMap(subDocData);

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

  void onMessageDelivered({
    required String userId,
    required String chatId,
    required String messageId,
  }) {
    ChatUtils.messages(
      userId: userId,
      chatId: chatId,
    ).doc(messageId).update(
      {
        'status': MessageStatusExtension.toStringValue(MessageStatus.delivered),
      },
    );
  }

  void onMessageSeen({
    required String userId,
    required String chatId,
    required String messageId,
  }) {
    ChatUtils.messages(
      userId: userId,
      chatId: chatId,
    ).doc(messageId).update(
      {
        'status': MessageStatusExtension.toStringValue(MessageStatus.seen),
      },
    );
  }
}
