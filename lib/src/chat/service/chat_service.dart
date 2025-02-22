import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/service/firestore_error_service.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  CollectionReference _chats(String? userId) => FirebaseFirestore.instance
      .collection("users")
      .doc(userId)
      .collection("chats");

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String? get _currentUserId => _currentUser?.uid;

  Future<Either<String, Chat>> createChat(Chat chat) async {
    if (_currentUser == null) {
      return Left("Authentication error: Please log in to create a chat.");
    }

    try {
      final docRef = _chats(_currentUserId).doc(chat.userId);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        return Left(
            "Chat creation failed: A chat with this user already exists.");
      }

      final updatedChat = chat.copyWith(userId: docRef.id);

      await docRef.set(updatedChat.toMap());

      return Right(updatedChat);
    } catch (error) {
      final errorMessage = _firestoreErrorService.handleException(error);
      return Left("Failed to create chat: $errorMessage");
    }
  }

  Future<Either<String, Chat>> updateChat(Chat chat) async {
    if (_currentUser == null) {
      return Left(
          "Authentication error: You must be logged in to update chats.");
    }

    try {
      await _chats(_currentUserId).doc(chat.userId).update(chat.toMap());
      return Right(chat);
    } catch (error) {
      final errorMessage = _firestoreErrorService.handleException(error);
      return Left("Failed to update chat: $errorMessage");
    }
  }

  Future<Either<String, bool>> deleteChatById(String chatId) async {
    if (_currentUser == null) {
      return Left(
          "Authentication error: You must be logged in to delete chats.");
    }

    try {
      await _chats(_currentUserId).doc(chatId).delete();
      return Right(true);
    } catch (error) {
      final errorMessage = _firestoreErrorService.handleException(error);
      return Left("Failed to delete chat: $errorMessage");
    }
  }

  Stream<Either<String, List<Chat>>> subscribeToChats() {
    if (_currentUser == null) {
      return Stream.value(
        Left("Authentication error: You must be logged in to get chats."),
      );
    }

    return _chats(_currentUserId)
        .snapshots()
        .asyncMap<Either<String, List<Chat>>>(
      (querySnapshot) async {
        try {
          final chats = querySnapshot.docs.map(
            (doc) {
              return Chat.fromMap(doc.data() as Map<String, dynamic>);
            },
          ).toList();

          return Right(chats);
        } catch (error) {
          final errorMessage = _firestoreErrorService.handleException(error);
          return Left("Failed to retrieve chats: $errorMessage");
        }
      },
    ).handleError(
      (error) {
        final errorMessage = _firestoreErrorService.handleException(error);
        return Left("Chat subscription error: $errorMessage");
      },
    );
  }
}
