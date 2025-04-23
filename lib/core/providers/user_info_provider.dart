import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/contact/model/base/contact_model.dart';
import '../../src/contact/view_model/contacts_view_model.dart';
import 'user_service_provider.dart';

/// Provides a [ContactModel] stream for a given [userId].
/// It first checks if the contact exists locally, otherwise fetches it from the backend.
final userInfoProvider = StreamProvider.family<ContactModel, String>(
  (ref, userId) {
    // Watch the UserService instance from the provider
    final userService = ref.watch(userServiceProvider);

    // Watch the registered contacts state
    final registeredContacts = ref.watch(contactsProvider);

    return registeredContacts.when(
      data: (contacts) {
        // Try to find the user in the local contacts list
        final contact = contacts.firstWhereOrNull((c) => c.id == userId);

        if (contact != null) {
          // If contact is found locally, return it as a stream
          return Stream.value(contact);
        } else {
          // Otherwise, stream user data from Firestore and convert it to a ContactModel
          return userService.streamUser(userId).map(
            (either) {
              return either.fold(
                // If there's an error, throw it to let the provider handle it
                (error) => throw error,
                // If success, convert UserModel to ContactModel
                (user) => ContactModel(
                  id: userId,
                  name: user
                      .phone.phoneNumber, // Using phone number as fallback name
                  phoneNumbers: [user.phone],
                  photo: user.photo,
                ),
              );
            },
          );
        }
      },
      // If contacts are still loading, return an empty stream
      loading: () => const Stream.empty(),
      // If an error occurred while loading contacts, forward the error
      error: (error, stack) => Stream.error(error),
    );
  },
);
