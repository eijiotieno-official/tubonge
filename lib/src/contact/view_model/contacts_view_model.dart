import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/base/contact_model.dart';
import '../model/service/contact_service.dart';
import '../model/provider/contact_service_provider.dart';

class ContactsViewModel extends StateNotifier<AsyncValue<List<ContactModel>>> {
  final ContactService _contactService;

  ContactsViewModel(this._contactService) : super(AsyncValue.loading()) {
    _load();
  }

  final Logger _logger = Logger();

  Future<void> _load() async {
    try {
      final Either<String, List<ContactModel>> result =
          await _contactService.loadContacts();

      result.fold(
        (error) {
          _logger.e('Error loading contacts: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
        (contacts) {
          state = AsyncValue.data(contacts);
          _logger.i('Loaded ${contacts.length} registered contacts.');
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

final contactsProvider =
    StateNotifierProvider<ContactsViewModel, AsyncValue<List<ContactModel>>>(
  (ref) {
    final ContactService contactService = ref.watch(contactServiceProvider);
    return ContactsViewModel(contactService);
  },
);
