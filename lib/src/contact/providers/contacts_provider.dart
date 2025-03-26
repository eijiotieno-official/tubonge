import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/contact_model.dart';
import '../services/contact_service.dart';
import 'contact_service_provider.dart';

class ContactsNotifier extends StateNotifier<AsyncValue<List<ContactModel>>> {
  final ContactService _contactService;
  final Logger _logger = Logger();

  ContactsNotifier(this._contactService) : super(AsyncValue.loading()) {
    _logger.i('ContactsNotifier created. Starting to load contacts.');
    _load();
  }

  Future<void> _load() async {
    try {
      final permissionResult = await _contactService.requestContactPermission();
      permissionResult.fold(
        (error) {
          _logger.e('Contact permission error: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
        (success) async {
          _logger.i('Contact permission granted.');
          final localResult = await _contactService.fetchLocalContacts();

          localResult.fold(
            (error) {
              _logger.e('Error fetching local contacts: $error');
              state = AsyncValue.error(error, StackTrace.current);
            },
            (contactsRaw) async {
              final contacts = contactsRaw
                  .map((contact) => ContactModel.fromContact(contact))
                  .toList();

              _logger.i('Fetched ${contacts.length} local contacts.');
              
              if (contacts.isEmpty) {
                state = AsyncValue.data([]);
                _logger.i('No local contacts found.');
              } else {
                final registeredResult =
                    await _contactService.getRegisteredContacts(contacts);

                registeredResult.fold(
                  (error) {
                    _logger.e('Error fetching registered contacts: $error');
                    state = AsyncValue.error(error, StackTrace.current);
                  },
                  (registeredContacts) {
                    state = AsyncValue.data(registeredContacts);
                    _logger.i(
                        'Loaded ${registeredContacts.length} registered contacts.');
                  },
                );
              }
            },
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Unexpected error in _load(): $e', stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    _logger.i('Refreshing contacts.');
    state = AsyncValue.loading();
    await _load();
  }

  ContactModel? getContactInfo(String? userId) {
    final contacts = state.value ?? [];
    final contact =
        contacts.firstWhereOrNull((contact) => contact.id == userId);
    if (contact == null) {
      _logger.w('Contact with userId $userId not found.');
    } else {
      _logger.i('Found contact with userId $userId.');
    }
    return contact;
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, AsyncValue<List<ContactModel>>>(
        (ref) {
  final contactService = ref.watch(contactServiceProvider);
  return ContactsNotifier(contactService);
});
