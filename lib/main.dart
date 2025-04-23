import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/cloud_functions_error_util.dart';
import 'core/services/router_service.dart';
import 'core/utils/firestore_error_util.dart';
import 'firebase_options.dart';
import 'src/chat/model/service/chat_notification_service.dart';
import 'src/chat/model/service/message_service.dart';
import 'src/contact/model/base/contact_model.dart';
import 'src/contact/model/service/contact_service.dart';

/// Handles background push notifications from Firebase Messaging.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Services used to process the message
  MessageService messageService =
      MessageService(firestoreErrorUtil: FirestoreErrorUtil());
  ContactService contactService =
      ContactService(cloudFunctionsErrorUtil: CloudFunctionsErrorUtil());

  // Load contacts to match sender ID with a name if available
  final Either<String, List<ContactModel>> contactsEither =
      await contactService.loadContacts();

  // Extract data from the incoming message
  final data = message.data;

  final senderId = data['sender_id'];
  final receiverId = data['receiver_id'];
  final messageId = data['message_id'];
  final messageText = data['message_text'];
  final senderPhoneNumber = data['sender_phoneNumber'];
  final senderPhoto = data['sender_photo'];

  String senderName;

  // Determine sender's name by matching with local contacts
  if (contactsEither.isRight()) {
    final contacts = contactsEither.fold((l) => <ContactModel>[], (r) => r);

    final matchingContact =
        contacts.firstWhereOrNull((contact) => contact.id == senderId);

    if (matchingContact != null) {
      senderName = matchingContact.name;
    } else {
      senderName = senderPhoneNumber;
    }
  } else {
    senderName = senderPhoneNumber;
  }

  // Notify that the message was delivered
  messageService.onMessageDelivered(
    userId: senderId,
    chatId: receiverId,
    messageId: messageId,
  );

  // Show a local push notification
  final ChatNotificationService chatNotificationService =
      ChatNotificationService();

  await chatNotificationService.showNotification(
    senderId: senderId,
    senderPhoto: senderPhoto,
    text: messageText,
    senderName: senderName,
  );
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firebase App Check to help prevent abuse
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.debug, // Use debug provider during development
  );

  // If in debug mode, use local Firebase emulators
  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  // Initialize local notification service
  final ChatNotificationService chatNotificationService =
      ChatNotificationService();
  await chatNotificationService.init();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Launch the app with ProviderScope to enable Riverpod
  runApp(const ProviderScope(child: MainApp()));
}

/// Root widget for the app, using Material Design and routing with GoRouter.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorSchemeSeed: Colors.green, // Seed color for light theme
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green, // Seed color for dark theme
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Use system theme setting (light/dark)
      routerConfig: AppRouter.router, // Use app's routing configuration
    );
  }
}
