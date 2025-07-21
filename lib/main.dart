import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/models/received_message_model.dart';
import 'core/services/router_service.dart';
import 'core/services/theme_service.dart';
import 'firebase_options.dart';
import 'src/chat/model/service/chat_notification_service.dart';
import 'src/chat/model/service/message_service.dart';
import 'src/contact/model/base/contact_model.dart';
import 'src/contact/model/service/contact_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  MessageService messageService = MessageService();
  ContactService contactService = ContactService();
  ChatNotificationService chatNotificationService = ChatNotificationService();

  Either<String, List<ContactModel>> contactsEither =
      await contactService.loadContacts();

  List<ContactModel> contacts =
      contactsEither.fold((l) => <ContactModel>[], (r) => r);

  ReceivedMessage receivedMessage =
      ReceivedMessage.fromRemoteMessage(message: message, contacts: contacts);

  messageService.onMessageDelivered(message: receivedMessage);

  await chatNotificationService.showNotification(message: receivedMessage);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance
      .activate(androidProvider: AndroidProvider.debug);

  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
