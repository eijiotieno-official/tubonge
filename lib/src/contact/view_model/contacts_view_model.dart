import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/user_util.dart';
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
      Either<String, List<ContactModel>> result =
          await _contactService.loadContacts();

      result.fold(
        (error) {
          
          if (error.contains('Permission to access contacts')) {
            state = AsyncValue.error(
              'Please grant contact permission in app settings to view your contacts.',
              StackTrace.current,
            );
          } else {
            state = AsyncValue.error(error, StackTrace.current);
          }
        },
        (contacts) {
          String? currentUserId = UserUtil.currentUserId;

          ContactModel? currentUserContact = contacts
              .firstWhereOrNull((contact) => contact.id == currentUserId);

          if (currentUserContact != null) {
            contacts.removeWhere((contact) => contact.id == currentUserId);

            contacts.add(currentUserContact.copyWith(
              name: "Personal Notes",
            ));
          }

          state = AsyncValue.data(contacts);
        },
      );
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
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
