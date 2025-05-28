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
  /// Private constructor to prevent instantiation
  AppRouter._();

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
    initialLocation: routesToPath(Routes.authChecker),
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _buildErrorScreen(context, state),
    routes: <GoRoute>[
      // Root route, checks auth state and wraps the app accordingly
      GoRoute(
        path: routesToPath(Routes.authChecker),
        builder: (BuildContext context, GoRouterState state) {
          return const AuthWrapperView();
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
            path: "chat/:id",
            builder: (BuildContext context, GoRouterState state) {
              final chatId = state.pathParameters['id'];
              if (chatId == null || chatId.isEmpty) {
                return _buildErrorScreen(
                  context,
                  state,
                  error: 'Invalid chat ID',
                );
              }
              return ChatDetailScreen(chatId: chatId);
            },
          ),
          // Nested route for contacts screen
          GoRoute(
            path: "contacts",
            builder: (BuildContext context, GoRouterState state) {
              return const ContactsScreen();
            },
          ),
        ],
      ),
    ],
  );

  /// Builds an error screen for invalid routes or errors
  static Widget _buildErrorScreen(
    BuildContext context,
    GoRouterState state, {
    String? error,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                error ?? 'Page not found',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested page "${state.uri.path}" could not be found.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => router.go(routesToPath(Routes.home)),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    if (userId == null || userId.isEmpty) {
      throw ArgumentError('User ID cannot be null or empty');
    }
    router.go(routesToPath(Routes.chatFromHome, id: userId));
  }

  /// Navigate to contacts screen
  static void goToContacts() {
    router.go(routesToPath(Routes.contacts));
  }

  /// Navigate back to the previous screen
  static void goBack() {
    router.pop();
  }

  /// Check if we can navigate back
  static bool canGoBack() {
    return router.canPop();
  }
}
