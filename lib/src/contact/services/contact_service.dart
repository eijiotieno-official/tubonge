import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/cloud_functions_error_service.dart';
import '../models/contact_model.dart';

class ContactService {
  final CloudFunctionsErrorService _cloudFunctionsErrorService;
  ContactService({
    required CloudFunctionsErrorService cloudFunctionsErrorService,
  }) : _cloudFunctionsErrorService = cloudFunctionsErrorService;

  Future<Either<String, List<flutter_contacts.Contact>>>
      fetchLocalContacts() async {
    try {
      final Either<String, bool> permissionResult = await isPermissionGranted();

      if (permissionResult.isLeft()) {
        return Left(
            permissionResult.swap().getOrElse(() => 'Permission denied'));
      }

      final List<flutter_contacts.Contact> contacts =
          await flutter_contacts.FlutterContacts.getContacts(
              withProperties: true);

      final List<flutter_contacts.Contact> filteredContacts = contacts
          .where((contact) =>
              contact.name.first.isNotEmpty && contact.phones.isNotEmpty)
          .map((contact) {
        contact.phones = contact.phones.map((phone) {
          phone.number = phone.number.replaceAll(' ', '');
          return phone;
        }).toList();

        return contact;
      }).toList();

      final List<flutter_contacts.Contact> uniqueContacts =
          <flutter_contacts.Contact>[];
      final Set<String> contactSet = <String>{};
      for (var contact in filteredContacts) {
        final String contactKey =
            '${contact.name.first}${contact.name.last}${contact.phones.map((phone) => phone.number).join()}';
        if (!contactSet.contains(contactKey)) {
          contactSet.add(contactKey);
          uniqueContacts.add(contact);
        }
      }

      return Right(uniqueContacts);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> isPermissionGranted() async {
    try {
      final PermissionStatus status = await Permission.contacts.status;
      if (status.isGranted) {
        return Right(true);
      } else if (status.isDenied || status.isRestricted) {
        return Left('Permission to access contacts is denied.');
      } else {
        return Left('Unknown permission status.');
      }
    } catch (e) {
      return Left('Error checking permission: $e');
    }
  }

  Future<Either<String, bool>> requestContactPermission() async {
    try {
      final PermissionStatus status = await Permission.contacts.request();
      if (status.isGranted) {
        return Right(true);
      } else if (status.isDenied || status.isRestricted) {
        return Left('Permission to access contacts was denied.');
      } else {
        return Left('Unknown permission status.');
      }
    } catch (e) {
      return Left('Error requesting permission: $e');
    }
  }

  Future<Either<String, List<ContactModel>>> getRegisteredContacts(
      List<ContactModel> contacts) async {
    try {
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
      final message = _cloudFunctionsErrorService.handleException(e);
      return Left(message);
    }
  }

  Future<Either<String, List<ContactModel>>> loadContacts() async {
    try {
      final Either<String, bool> permissionResult =
          await requestContactPermission();

      return await permissionResult.fold(
        (error) async => Left(error),
        (success) async {
          final Either<String, List<flutter_contacts.Contact>> localResult =
              await fetchLocalContacts();

          return await localResult.fold(
            (error) async => Left(error),
            (contactsRaw) async {
              final List<ContactModel> contacts = contactsRaw
                  .map((contact) => ContactModel.fromContact(contact))
                  .toList();

              if (contacts.isEmpty) {
                return Right([]);
              } else {
                return await getRegisteredContacts(contacts);
              }
            },
          );
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}
