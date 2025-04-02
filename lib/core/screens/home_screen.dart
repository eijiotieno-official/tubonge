import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/auth/controller/sign_out_controller.dart';
import '../../src/chat/services/message_service.dart';
import '../../src/chat/views/chats_list_view.dart';
import '../../src/contact/providers/contacts_provider.dart';
import '../../src/contact/screens/contacts_screen.dart';
import '../services/router_service.dart';
import '../views/avatar_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ReceivedAction? receivedAction;
  const HomeScreen({super.key, required this.receivedAction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    if (widget.receivedAction != null) {
      final userId = widget.receivedAction?.payload!['chatId'];
      if (userId != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            RouterService.goToChat(userId);
          },
        );
      }
    }
    super.initState();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        final data = message.data;
        final senderId = data['sender_id'];
        final messageId = data['message_id'];
        final messageText = data['message_text'];
        final senderPhone = data['sender_phone'];
        final senderPhoto = data['sender_photo'];

        final contacts = ref.watch(contactsProvider).value ?? [];

        final contact =
            contacts.firstWhereOrNull((contact) => contact.id == senderId);

        String title = contact == null ? senderPhone : contact.name;

        // Update message status to 'delivered'
        MessageService().onMessageDelivered(
          userId: senderId,
          chatId: FirebaseAuth.instance.currentUser!.uid,
          messageId: messageId,
        );

        // Show a snack bar with message details
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
                leading: AvatarView(imageUrl: senderPhoto),
                title: Text(title),
                subtitle: Text(messageText),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    if (value == 'logout') {
      await ref.read(signOutProvider.notifier).call();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: ChatsListView(),
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
