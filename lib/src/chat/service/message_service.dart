import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/service/firestore_error_service.dart';
import '../models/message_model.dart';

class MessageService {
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String? get _currentUserId => _currentUser?.uid;

  CollectionReference _messages({
    required String? userId,
    required String chatId,
  }) =>
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("chats")
          .doc(chatId)
          .collection("messages");

  Either<String, Message> createMessage(Message message) {
    if (_currentUserId == null) {
      return Left("Authentication error: Please log in to send messages.");
    }

    try {
      final docRef = _messages(
        userId: _currentUserId,
        chatId: message.receiver,
      ).doc();

      final updatedMessage = message.copyWith(
        sender: _currentUserId,
        id: docRef.id,
        status: message.receiver == _currentUserId
            ? MessageStatus.seen
            : MessageStatus.none,
      );

      docRef.set(updatedMessage.toMap());
      return Right(updatedMessage);
    } catch (e) {
      final errorMessage = _firestoreErrorService.handleException(e);
      return Left("Failed to send message: $errorMessage");
    }
  }

  Either<String, Message> updateMessage(Message message) {
    if (_currentUser == null) {
      return Left(
          "Authentication error: You must be logged in to edit messages.");
    }

    try {
      _messages(
        userId: _currentUserId,
        chatId: message.receiver,
      ).doc(message.id).update(message.toMap());

      return Right(message);
    } catch (e) {
      final errorMessage = _firestoreErrorService.handleException(e);
      return Left("Failed to update message: $errorMessage");
    }
  }

  Either<String, String> deleteMessage(Message message) {
    if (_currentUser == null) {
      return Left(
          "Authentication error: You must be logged in to delete messages.");
    }

    try {
      _messages(userId: message.sender, chatId: message.receiver)
          .doc(message.id)
          .delete();

      _messages(userId: message.receiver, chatId: message.sender)
          .doc(message.id)
          .delete();

      return Right("Message deleted successfully.");
    } catch (e) {
      final errorMessage = _firestoreErrorService.handleException(e);
      return Left("Failed to delete message: $errorMessage");
    }
  }

  Stream<Either<String, List<Message>>> subscribeToMessages({
    required String chatId,
    required List<Message> initialMessages,
  }) {
    if (_currentUser == null) {
      return Stream.value(
        Left("Authentication error: You must be logged in to view messages."),
      );
    }

    return _messages(userId: _currentUserId, chatId: chatId)
        .snapshots()
        .asyncMap<Either<String, List<Message>>>(
      (QuerySnapshot querySnapshot) {
        try {
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
        } catch (e) {
          final errorMessage = _firestoreErrorService.handleException(e);
          return Left("Error retrieving messages: $errorMessage");
        }
      },
    );
  }

  List<Message> sortItemsByDate(
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

  String formatTimeSent(DateTime dateTime) {
    final today = DateTime.now();
    final difference = today.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference <= 7) {
      return DateFormat.EEEE()
          .format(dateTime); // Outputs "Monday", "Tuesday", etc.
    } else {
      return DateFormat('d MMM yyyy').format(dateTime); // Outputs "7 Jan 2025"
    }
  }
}
