import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/auth/view_model/sign_out_view_model.dart';
import '../../src/chat/model/provider/message_service_provider.dart';
import '../../src/chat/model/service/chat_notification_service.dart';
import '../../src/chat/view/widgets/chats_list.dart';
import '../../src/contact/model/base/contact_model.dart';
import '../../src/contact/model/service/contact_service.dart';
import '../../src/contact/view/screens/contacts_screen.dart';
import '../../src/contact/view_model/contacts_view_model.dart';
import '../models/received_message_model.dart';
import '../services/fcm_service.dart';
import '../services/router_service.dart';
import '../views/avatar_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ReceivedAction? receivedAction;
  const HomeScreen({super.key, required this.receivedAction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  Future<void> _initializePermissions() async {
    await ChatNotificationService().init();

    await ContactService().requestPermission();
  }

  void _setupFCMListener() {
    _fcmSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        List<ContactModel> contacts = ref.read(contactsProvider).value ?? [];

        ReceivedMessage receivedMessage = ReceivedMessage.fromRemoteMessage(
            message: message, contacts: contacts);

        ref
            .read(messageServiceProvider)
            .onMessageDelivered(message: receivedMessage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              behavior: SnackBarBehavior.floating,
              content: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AvatarView(imageUrl: receivedMessage.senderPhoto),
                title: Text(receivedMessage.senderName),
                subtitle: Text(receivedMessage.text),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.receivedAction != null) {
      ReceivedMessage message =
          ReceivedMessage.fromPayload(widget.receivedAction?.payload);

      String userId = message.receiverId;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          AppRouter.goToChat(userId);
        },
      );
    }

    _initializePermissions();
    _setupFCMListener();
    _initializeFCMTokenRefresh();
  }

  void _initializeFCMTokenRefresh() {
    FCMService.initializeTokenRefresh();
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    FCMService.dispose();
    super.dispose();
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'logout') {
      if (!mounted) return;
      await ref.read(signOutProvider.notifier).call();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tubonge"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          PopupMenuButton<String>(
            elevation: 1,
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuSelection,
            borderRadius: BorderRadius.circular(16.0),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ChatsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ContactsScreen();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
