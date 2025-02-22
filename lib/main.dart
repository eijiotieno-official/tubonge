import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubonge/core/widget/home_view.dart';

import 'core/provider/theme_provider.dart';
import 'firebase_options.dart';
import 'src/auth/view/widget/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ref.watch(themeProvider(context)),
      home: HomeView(),
    );
  }
}
