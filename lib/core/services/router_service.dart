import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importing app-specific screens and widgets
import '../../src/auth/view/screens/auth_screen.dart';
import '../../src/auth/view/widgets/auth_wrapper_view.dart';
import '../../src/chat/view/screens/chat_detail_screen.dart';
import '../../src/contact/view/screens/contacts_screen.dart';
import '../screens/home_screen.dart';

/// Enum to represent all available named routes in the app
enum Routes {
  authChecker,
  auth,
  home,
  contacts,
  chatFromHome,
  chatFromContacts,
}

/// Class that handles all routing logic for the application
class AppRouter {
  /// Converts [Routes] enum to corresponding path string.
  /// If [id] is needed in the route (like for chat screens), it is interpolated into the path.
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
        return '/home/chat/${id ?? ':id'}'; // dynamic or placeholder ID
      case Routes.chatFromContacts:
        return '/home/contacts/chat/${id ?? ':id'}'; // dynamic or placeholder ID
    }
  }

  /// Main router instance configured with all routes using GoRouter
  static final GoRouter router = GoRouter(
    initialLocation:
        routesToPath(Routes.authChecker), // Initial route of the app
    routes: <GoRoute>[
      // Root route, checks auth state and wraps the app accordingly
      GoRoute(
        path: routesToPath(Routes.authChecker),
        builder: (BuildContext context, GoRouterState state) {
          return AuthWrapperView();
        },
      ),
      // Auth screen route
      GoRoute(
        path: routesToPath(Routes.auth),
        builder: (BuildContext context, GoRouterState state) {
          return const AuthScreen();
        },
      ),
      // Home screen route, optionally receives notification action
      GoRoute(
        path: routesToPath(Routes.home),
        builder: (BuildContext context, GoRouterState state) {
          final receivedAction = state.extra as ReceivedAction?;
          return HomeScreen(receivedAction: receivedAction);
        },
        routes: [
          // Nested route for chat detail screen (from home)
          GoRoute(
            path: "chat/:id", // Uses path parameter `id`
            builder: (BuildContext context, GoRouterState state) {
              return ChatDetailScreen(
                chatId: state.pathParameters['id'] ??
                    "", // Extracts `id` from route
              );
            },
          ),
          // Nested route for contacts screen
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

  /// Replace current route with a new one and optionally pass [ReceivedAction] data
  static void replaceTo(Routes route, {ReceivedAction? receivedAction}) {
    router.replace(
      routesToPath(route),
      extra: receivedAction,
    );
  }

  /// Navigate to home screen, passing along notification [ReceivedAction]
  static void goToHomeWithReceivedAction(ReceivedAction receivedAction) {
    router.go(
      routesToPath(Routes.home),
      extra: receivedAction,
    );
  }

  /// Navigate to chat screen from home, using provided [userId]
  static void goToChat(String? userId) {
    router.go(routesToPath(Routes.chatFromHome, id: userId));
  }

  /// Navigate to contacts screen
  static void goToContacts() async {
    router.go(routesToPath(Routes.contacts));
  }
}
