import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PermissionService {


  static Future<Either<String, bool>> requestFCMPermission() async {
    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        return Right(true);
      } else {
        // Add a small delay and retry once to handle timing issues
        await Future.delayed(const Duration(milliseconds: 500));
        final NotificationSettings retrySettings =
            await FirebaseMessaging.instance.getNotificationSettings();

        if (retrySettings.authorizationStatus ==
            AuthorizationStatus.authorized) {
          return Right(true);
        } else {
          return Left('FCM permission was denied.');
        }
      }
    } catch (e) {
      return Left('Error requesting FCM permission: $e');
    }
  }

  static Future<Either<String, bool>> checkFCMPermission() async {
    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        return Right(true);
      } else {
        // Add a small delay and retry once to handle timing issues
        await Future.delayed(const Duration(milliseconds: 500));
        final NotificationSettings retrySettings =
            await FirebaseMessaging.instance.getNotificationSettings();

        if (retrySettings.authorizationStatus ==
            AuthorizationStatus.authorized) {
          return Right(true);
        } else {
          return Left('FCM permission is not granted.');
        }
      }
    } catch (e) {
      return Left('Error checking FCM permission: $e');
    }
  }

  static Future<Either<String, String>> getFCMToken() async {
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

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static String getPermissionExplanation(String permission) {
    switch (permission) {
      case 'notifications':
        return 'Notification permission is required to receive message notifications when the app is in the background.';
      case 'contacts':
        return 'Contact permission is required to find and connect with your contacts who are using this app.';
      case 'fcm':
        return 'Push notification permission is required to receive real-time messages from other users.';
      default:
        return 'This permission is required for the app to function properly.';
    }
  }
}
