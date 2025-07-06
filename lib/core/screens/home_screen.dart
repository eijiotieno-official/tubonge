import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/auth/model/provider/auth_state_provider.dart';
import '../../src/auth/view_model/sign_out_view_model.dart';
import '../../src/chat/model/provider/message_service_provider.dart';
import '../../src/chat/view/widgets/chats_list_view.dart';
import '../../src/contact/view/screens/contacts_screen.dart';
import '../../src/contact/view_model/contacts_view_model.dart';
import '../models/received_message_model.dart';
import '../services/router_service.dart';
import '../views/avatar_view.dart';

/// HomeScreen displays the main screen with a list of chats and a menu for actions like logout.
/// It also handles incoming push notifications for new messages.
class HomeScreen extends ConsumerStatefulWidget {
  final ReceivedAction?
      receivedAction; // Used for deep linking to specific chat
  const HomeScreen({super.key, required this.receivedAction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // If there is a received push notification action (like a direct message),
    // navigate to the corresponding chat screen.
    if (widget.receivedAction != null) {
      final message =
          ReceivedMessage.fromPayload(widget.receivedAction?.payload);

      final userId = message.receiverId;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          AppRouter.goToChat(userId); // Navigate to chat with the user
        },
      );
    }

    // Listen for incoming Firebase push notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        // Watch the contacts list from Riverpod
        final contacts = ref.watch(contactsProvider).value ?? [];

        final receivedMessage = ReceivedMessage.fromRemoteMessage(
            message: message, contacts: contacts);

        // Mark the message as delivered
        ref
            .read(messageServiceProvider)
            .onMessageDelivered(message: receivedMessage);

        // Show a snackbar with the message details
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
                leading: AvatarView(
                    imageUrl:
                        receivedMessage.senderPhoto), // Display sender's photo
                title:
                    Text(receivedMessage.senderName), // Display sender's name
                subtitle: Text(receivedMessage.text), // Display message content
              ),
            ),
          );
        }
      },
    );
  }

  /// Handles menu actions, such as logging out.
  Future<void> _handleMenuSelection(String value) async {
    if (value == 'logout') {
      // Calls the signOut provider to log the user out
      await ref.read(signOutProvider.notifier).call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tubonge"), // App name
        actions: [
          // Search icon button (functionality not defined yet)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          // More options menu (logout in this case)
          PopupMenuButton<String>(
            elevation: 1,
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuSelection, // Call when menu item is selected
            borderRadius: BorderRadius.circular(16.0),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout', // Logout option
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ChatsListView(), // Displays list of chats
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to contacts screen to add a new contact or chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ContactsScreen();
              },
            ),
          );
        },
        child: const Icon(Icons.add), // Icon for adding a new contact/chat
      ),
    );
  }
}
