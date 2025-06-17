import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

import '../../../../core/models/received_message_model.dart';
import '../../../../core/services/router_service.dart';

class ChatNotificationService {
  ChatNotificationService() {
    init();
  }

  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  ReceivedAction? initialAction;

  Future<void> init() async {
    final bool isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications();
    }
    await _initialize();
  }

  Future<void> _initialize() async {
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

  Future<void> _setListener() async {
    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    initialAction = receivedAction;

    AppRouter.router.go(
      AppRouter.routesToPath(Routes.home),
      extra: receivedAction,
    );
  }

  Future<void> showNotification({required ReceivedMessage message}) async {
    final Random random = Random();

    final int id = random.nextInt(10000) + 1;

    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'message_channel',
        title: message.senderName,
        bigPicture: message.senderPhoto,
        body: message.text,
        payload: message.toPayload(),
        notificationLayout: NotificationLayout.Messaging,
      ),
    );
  }
}
