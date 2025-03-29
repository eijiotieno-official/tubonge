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

import 'core/services/router_service.dart';
import 'firebase_options.dart';
import 'src/chat/services/chat_notification_service.dart';
import 'src/chat/services/message_service.dart';
import 'src/contact/models/contact_model.dart';
import 'src/contact/services/contact_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  MessageService messageService = MessageService();
  ContactService contactService = ContactService();

  final Either<String, List<ContactModel>> contactsEither =
      await contactService.loadContacts();

  final data = message.data;

  final senderId = data['sender_id'];
  final receiverId = data['receiver_id'];
  final messageId = data['message_id'];
  final messageText = data['message_text'];
  final senderPhoneNumber = data['sender_phoneNumber'];
  final senderPhoto = data['sender_photo'];

  String senderName;

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

  messageService.onMessageDelivered(
      userId: senderId, chatId: receiverId, messageId: messageId);

  await ChatNotificationService.showNotification(
    senderId: senderId,
    senderPhoto: senderPhoto,
    text: messageText,
    senderName: senderName,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  if (kDebugMode) {
    // Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

    // Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    // Functions emulator
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    // Storage emulator
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  await ChatNotificationService.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      routerConfig: RouterService.router,
    );
  }
}
