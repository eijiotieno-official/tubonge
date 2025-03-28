import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../src/auth/screens/auth_screen.dart';
import '../../src/auth/views/auth_wrapper_view.dart';
import '../../src/chat/screens/chat_detail_screen.dart';
import '../../src/contact/screens/contacts_screen.dart';
import '../screens/home_screen.dart';

enum Routes {
  authChecker,
  auth,
  home,
  contacts,
  chatFromHome,
  chatFromContacts,
}

class RouterService {
  static String routesToPath(Routes route, {String? id}) {
    switch (route) {
      case Routes.authChecker:
        return '/';
      case Routes.auth:
        return '/auth';
      case Routes.home:
        return '/home';
      case Routes.contacts:
        return '/home/contacts';
      case Routes.chatFromHome:
        return '/home/chat/${id ?? ':id'}';
      case Routes.chatFromContacts:
        return '/home/contacts/chat/${id ?? ':id'}';
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: routesToPath(Routes.authChecker),
    routes: <GoRoute>[
      GoRoute(
        path: routesToPath(Routes.authChecker),
        builder: (BuildContext context, GoRouterState state) {
          return AuthWrapperView();
        },
      ),
      GoRoute(
        path: routesToPath(Routes.auth),
        builder: (BuildContext context, GoRouterState state) {
          return const AuthScreen();
        },
      ),
      GoRoute(
        path: routesToPath(Routes.home),
        builder: (BuildContext context, GoRouterState state) {
          final receivedAction = state.extra as ReceivedAction?;
          return HomeScreen(receivedAction: receivedAction);
        },
        routes: [
          GoRoute(
            path: "chat/:id",
            builder: (BuildContext context, GoRouterState state) {
              return ChatDetailScreen(
                chatId: state.pathParameters['id'] ?? "",
              );
            },
          ),
          GoRoute(
            path: "contacts",
            builder: (BuildContext context, GoRouterState state) {
              return ContactsScreen();
            },
          ),
        ],
      ),
    ],
  );

  static void replaceTo(Routes route, {ReceivedAction? receivedAction}) {
    router.replace(
      routesToPath(route),
      extra: receivedAction,
    );
  }

  static void goToHomeWithReceivedAction(ReceivedAction receivedAction) {
    router.go(
      routesToPath(Routes.home),
      extra: receivedAction,
    );
  }

  static void goToChat(String? userId) {
    router.go(routesToPath(Routes.chatFromHome, id: userId));
  }

  static void goToContacts() async {
    router.go(routesToPath(Routes.contacts));
  }
}
