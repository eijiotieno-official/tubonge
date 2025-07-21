import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;

import '../../../../core/utils/cloud_functions_error_util.dart';
import '../base/contact_model.dart';

class ContactService {
  Future<Either<String, bool>> requestPermission() async {
    try {
      bool isPermissionGranted =
          await flutter_contacts.FlutterContacts.requestPermission();

      if (isPermissionGranted) {
        return const Right(true);
      } else {
        return const Left('Contacts permission denied');
      }
    } catch (e) {
      return Left('Failed to request contacts permission: $e');
    }
  }

  Future<Either<String, List<flutter_contacts.Contact>>>
      _fetchLocalContacts() async {
    try {
      Either<String, bool> isPermissionGranted = await requestPermission();

      if (isPermissionGranted.isRight()) {
        List<flutter_contacts.Contact> contacts =
            await flutter_contacts.FlutterContacts.getContacts(
                withProperties: true);

        List<flutter_contacts.Contact> filteredContacts = contacts
            .where((contact) =>
                contact.name.first.isNotEmpty && contact.phones.isNotEmpty)
            .map((contact) {
          List<flutter_contacts.Phone> phones = contact.phones;

          List<flutter_contacts.Phone> cleanedPhones = phones.map((phone) {
            final cleanedNumber = phone.number
                .toString()
                .replaceAll(' ', '')
                .replaceAll(RegExp(r'[^\d+]'), '');
            return flutter_contacts.Phone(cleanedNumber);
          }).toList();

          return flutter_contacts.Contact(
            name: contact.name,
            phones: cleanedPhones,
          );
        }).toList();

        final List<flutter_contacts.Contact> uniqueContacts =
            _getUniqueContactsByPhone(filteredContacts);

        return Right(uniqueContacts);
      } else {
        return Left('Contacts permission denied');
      }
    } catch (e) {
      return Left("Failed to fetch local contacts: $e");
    }
  }

  List<flutter_contacts.Contact> _getUniqueContactsByPhone(
      List<flutter_contacts.Contact> contacts) {
    final Map<String, flutter_contacts.Contact> uniqueContacts = {};

    for (var contact in contacts) {
      // Check each phone number individually
      for (var phone in contact.phones) {
        String phoneNumber = phone.number;

        // If this phone number is already in our map, skip this contact
        if (uniqueContacts.containsKey(phoneNumber)) {
          continue;
        }
      }

      // If we reach here, none of this contact's phone numbers exist yet
      // Use the first phone number as the key
      if (contact.phones.isNotEmpty) {
        String phoneKey = contact.phones.first.number;
        uniqueContacts[phoneKey] = contact;
      }
    }

    return uniqueContacts.values.toList();
  }

  Future<Either<String, List<ContactModel>>> _getRegisteredContacts(
      List<ContactModel> contacts) async {
    try {
      if (contacts.isEmpty) {
        return Right([]);
      }

      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('request_registered_contacts');

      final Map<String, List<Map<String, dynamic>>> body = {
        'contacts': contacts.map((c) => c.toMap()).toList()
      };

      final HttpsCallableResult response = await callable.call(body);

      final data = response.data;

      final List<ContactModel> registeredContacts =
          (data['registeredContacts'] as List)
              .map((contact) => ContactModel.fromJson(contact))
              .toList();

      return Right(registeredContacts);
    } catch (e) {
      final message = CloudFunctionsErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Future<Either<String, List<ContactModel>>> loadContacts() async {
    Either<String, List<flutter_contacts.Contact>> localResult =
        await _fetchLocalContacts();

    return localResult.fold(
      (localError) => Left(localError),
      (localContacts) async {
        List<ContactModel> contacts = localContacts
            .map((contact) => ContactModel.fromContact(contact))
            .toList();

        if (contacts.isEmpty) {
          return Right([]);
        } else {
          Either<String, List<ContactModel>> registeredContactsResult =
              await _getRegisteredContacts(contacts);

          return registeredContactsResult.fold(
            (registeredError) => Left(registeredError),
            (registeredContacts) => Right(registeredContacts),
          );
        }
      },
    );
  }
}
