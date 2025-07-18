import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/base/contact_model.dart';
import '../model/service/contact_service.dart';

class ContactsViewModel extends StateNotifier<AsyncValue<List<ContactModel>>> {
  ContactsViewModel() : super(AsyncValue.data([])) {
    _load();
  }

  final ContactService _contactService = ContactService();

  Future<void> _load() async {
    state = AsyncValue.loading();
    try {
      final Either<String, List<ContactModel>> result =
          await _contactService.loadContacts();

      result.fold(
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
        },
        (contacts) {
          state = AsyncValue.data(contacts);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _load();
  }

  ContactModel? getContactById(String? userId) {
    final List<ContactModel> contacts = state.value ?? [];

    final ContactModel? contact =
        contacts.firstWhereOrNull((contact) => contact.id == userId);

    return contact;
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsViewModel, AsyncValue<List<ContactModel>>>(
  (ref) {
    return ContactsViewModel();
  },
);
