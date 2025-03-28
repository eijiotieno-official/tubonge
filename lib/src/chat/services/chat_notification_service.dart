import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

import '../../../core/services/router_service.dart';

class ChatNotificationService {
  static final AwesomeNotifications _awesomeNotifications =
      AwesomeNotifications();

  static ReceivedAction? initialAction;

  /// Requests permission to send notifications if not already allowed.
  static Future<void> init() async {
    final isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications();
    }
    await _initialize();
  }

  /// Initializes notification channels and sets up listeners.
  static Future<void> _initialize() async {
    await _awesomeNotifications.initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'message_channel',
          channelName: 'Message notifications',
          channelDescription: 'Notification channel for messages',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Notification,
        ),
      ],
    );

    await _setListener();
  }

  /// Sets up notification action listener.
  static Future<void> _setListener() async {
    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
    );
  }

  /// Handles notification action received.
  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    initialAction = receivedAction;

    // Use RouterService to navigate to Home with ReceivedAction
    RouterService.router.go(
      RouterService.routesToPath(Routes.home),
      extra: receivedAction, // Pass ReceivedAction to the HomeScreen
    );
  }

  /// Shows a notification with the provided details.
  static Future<void> showNotification({
    required String senderId,
    required String senderPhoto,
    required String senderName,
    required String text,
  }) async {
    final Random random = Random();

    final int id = random.nextInt(10000) + 1;

    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'message_channel',
        title: senderName,
        bigPicture: senderPhoto,
        body: text,
        payload: {
          'chatId': senderId,
          'text': text,
        },
        notificationLayout: NotificationLayout.Messaging,
      ),
    );
  }
}
