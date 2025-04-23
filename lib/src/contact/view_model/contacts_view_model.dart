import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/base/contact_model.dart';
import '../model/service/contact_service.dart';
import '../model/provider/contact_service_provider.dart';

/// ViewModel responsible for managing and exposing contact data to the UI.
/// Uses Riverpod's StateNotifier with AsyncValue to handle loading, error, and data states.
class ContactsViewModel extends StateNotifier<AsyncValue<List<ContactModel>>> {
  final ContactService _contactService;

  /// Constructor initializes the state to loading and immediately triggers contact loading.
  ContactsViewModel(this._contactService) : super(AsyncValue.loading()) {
    _load(); // Load contacts on initialization
  }

  final Logger _logger = Logger(); // Logger for debug/info/error output

  /// Loads contacts using the service and updates the state based on success or failure.
  Future<void> _load() async {
    try {
      final Either<String, List<ContactModel>> result =
          await _contactService.loadContacts();

      result.fold(
        // On failure, log and update state with error
        (error) {
          _logger.e('Error loading contacts: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
        // On success, update state with contact list
        (contacts) {
          state = AsyncValue.data(contacts);
          _logger.i('Loaded ${contacts.length} registered contacts.');
        },
      );
    } catch (e, stackTrace) {
      // Handle any unexpected exceptions
      _logger.e('Unexpected error in _load(): $e', stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refreshes the contact list by setting state to loading and reloading data.
  Future<void> refresh() async {
    _logger.i('Refreshing contacts.');
    state = AsyncValue.loading();
    await _load();
  }

  /// Retrieves a contact by [userId] from the current state.
  /// Returns null if the contact is not found.
  ContactModel? getContactInfo(String? userId) {
    final List<ContactModel> contacts = state.value ?? [];

    final ContactModel? contact =
        contacts.firstWhereOrNull((contact) => contact.id == userId);

    if (contact == null) {
      _logger.w('Contact with userId $userId not found.');
    } else {
      _logger.i('Found contact with userId $userId.');
    }
    return contact;
  }
}

/// Provider for the [ContactsViewModel] which exposes the list of contacts as AsyncValue.
final contactsProvider =
    StateNotifierProvider<ContactsViewModel, AsyncValue<List<ContactModel>>>(
  (ref) {
    // Watch and inject the ContactService into the ViewModel
    final ContactService contactService = ref.watch(contactServiceProvider);
    return ContactsViewModel(contactService);
  },
);
