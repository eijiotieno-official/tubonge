import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) {
    // Define the scopes needed
    const List<String> scopes = <String>[
      'email',
    ];

    // Initialize GoogleSignIn with the web client ID for Flutter Web
    GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          "1025584618741-2he44irob6nj4oc23cjqe5043irl6gv6.apps.googleusercontent.com", // Replace with your web client ID
      scopes: scopes,
    );

    return googleSignIn;
  },
);
