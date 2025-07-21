import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/user_util.dart';
import '../models/user_model.dart';

class FCMService {
  static StreamSubscription<String>? _tokenRefreshSubscription;

  /// Initialize FCM token refresh listener
  static void initializeTokenRefresh() {
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        _handleTokenRefresh(newToken);
      },
      onError: (error) {
        debugPrint('FCM token refresh error: $error');
      },
    );
  }

  /// Handle token refresh by updating the user's tokens in Firestore
  static Future<void> _handleTokenRefresh(String newToken) async {
    try {
      debugPrint('FCM token refreshed: $newToken');

      final currentUserId = UserUtil.currentUserId;
      if (currentUserId == null) {
        debugPrint('No current user ID found for token refresh');
        return;
      }

      // Get current user document
      final userDoc = await UserUtil.users.doc(currentUserId).get();
      if (!userDoc.exists) {
        debugPrint('User document not found for token refresh');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentUser = UserModel.fromMap(userData);

      // Add new token if it doesn't exist
      final currentTokens = List<String>.from(currentUser.tokens);
      if (!currentTokens.contains(newToken)) {
        currentTokens.add(newToken);

        // Update user document with new token
        await UserUtil.users.doc(currentUserId).update({
          'tokens': currentTokens,
        });

        debugPrint('FCM token updated in Firestore for user: $currentUserId');
      }
    } catch (e) {
      debugPrint('Error handling FCM token refresh: $e');
    }
  }

  /// Get current FCM token
  static Future<Either<String, String>> getCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        return Left('FCM token is null');
      }
      return Right(token);
    } catch (e) {
      return Left('Error fetching FCM token: $e');
    }
  }

  /// Manually refresh FCM token
  static Future<Either<String, String>> refreshToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        return Left('FCM token is null');
      }

      // Handle the token refresh manually
      await _handleTokenRefresh(token);

      return Right(token);
    } catch (e) {
      return Left('Error refreshing FCM token: $e');
    }
  }

  /// Clean up resources
  static void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}
