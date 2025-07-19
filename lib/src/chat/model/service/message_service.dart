import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/models/received_message_model.dart';
import '../../../../core/utils/firestore_error_util.dart';
import '../../../../core/utils/user_util.dart';
import '../base/message_model.dart';
import '../util/chat_utils.dart';

class MessageService {
  Either<String, Message> createMessage(Message? message) {
    try {
      if (message == null) {
        return Left("Create a message");
      }

      if (UserUtil.currentUserId == null) {
        return Left("User not log in");
      }

      final DocumentReference<Object?> docRef = ChatUtil.messages(
        userId: UserUtil.currentUserId ?? "",
        chatId: message.receiver,
      ).doc();

      final Message updatedMessage = message.copyWith(
        sender: UserUtil.currentUserId,
        id: docRef.id,
        status: message.receiver == UserUtil.currentUserId
            ? MessageStatus.seen
            : MessageStatus.none,
      );

      docRef.set(updatedMessage.toMap());

      return Right(updatedMessage);
    } catch (e) {
      final message = FirestoreErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Either<String, bool> deleteMessage(Message message) {
    try {
      ChatUtil.messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc(message.id).delete();

      return Right(true);
    } catch (e) {
      final message = FirestoreErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Either<String, bool> updateMessage(Message message) {
    try {
      ChatUtil.messages(
        userId: message.sender,
        chatId: message.receiver,
      ).doc(message.id).update(message.toMap());

      return Right(true);
    } catch (e) {
      final message = FirestoreErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Stream<Either<String, List<Message>>> streamMessages({
    required String userId,
    required String chatId,
    required List<Message> initialMessages,
  }) {
    return ChatUtil.messages(userId: userId, chatId: chatId)
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
        final message = FirestoreErrorUtil.handleException(error);
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
    required ReceivedMessage message,
  }) {
    ChatUtil.messages(
      userId: message.senderId,
      chatId: message.receiverId,
    ).doc(message.messageId).update(
      {
        'status': MessageStatus.delivered.toMap(),
      },
    );
  }

  void onMessageSeen({
    required String userId,
    required String chatId,
    required String messageId,
  }) {
    ChatUtil.messages(
      userId: userId,
      chatId: chatId,
    ).doc(messageId).update(
      {
        'status': MessageStatus.seen.toMap(),
      },
    );
  }
}
