import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/utils/cloud_functions_error_util.dart';
import '../base/contact_model.dart';

class ContactService {
  final CloudFunctionsErrorUtil _cloudFunctionsErrorUtil;
  ContactService({
    required CloudFunctionsErrorUtil cloudFunctionsErrorUtil,
  }) : _cloudFunctionsErrorUtil = cloudFunctionsErrorUtil;
// Method to fetch local contacts with permission checks and filtering
  Future<Either<String, List<flutter_contacts.Contact>>>
      _fetchLocalContacts() async {
    try {
      // Check if the permission to access contacts is granted
      final Either<String, bool> permissionResult =
          await _isPermissionGranted();

      // If permission is denied, return an error message
      if (permissionResult.isLeft()) {
        return Left(
            permissionResult.swap().getOrElse(() => 'Permission denied'));
      }

      // Fetch the contacts with additional properties (like phone numbers)
      final List<flutter_contacts.Contact> contacts =
          await flutter_contacts.FlutterContacts.getContacts(
              withProperties: true);

      // Filter contacts to ensure they have a name and at least one phone number
      final List<flutter_contacts.Contact> filteredContacts = contacts
          .where((contact) =>
              contact.name.first.isNotEmpty && contact.phones.isNotEmpty)
          .map((contact) {
        // Clean phone numbers by removing spaces
        contact.phones = contact.phones.map((phone) {
          phone.number = phone.number.replaceAll(' ', '');
          return phone;
        }).toList();

        return contact;
      }).toList();

      // Remove duplicate contacts based on a combination of name and phone number
      final List<flutter_contacts.Contact> uniqueContacts =
          <flutter_contacts.Contact>[];
      final Set<String> contactSet = <String>{};

      for (var contact in filteredContacts) {
        // Create a unique key based on the contact's name and phone number
        final String contactKey =
            '${contact.name.first}${contact.name.last}${contact.phones.map((phone) => phone.number).join()}';

        // If the key doesn't already exist, add the contact to uniqueContacts
        if (!contactSet.contains(contactKey)) {
          contactSet.add(contactKey);
          uniqueContacts.add(contact);
        }
      }

      // Return the list of unique contacts
      return Right(uniqueContacts);
    } catch (e) {
      // Return the error message if an exception occurs
      return Left(e.toString());
    }
  }

  // Method to check if permission to access contacts is granted
  Future<Either<String, bool>> _isPermissionGranted() async {
    try {
      // Get the current status of the contacts permission
      final PermissionStatus status = await Permission.contacts.status;

      // If permission is granted, return success (Right)
      if (status.isGranted) {
        return Right(true);
      }
      // If permission is denied or restricted, return an error message (Left)
      else if (status.isDenied || status.isRestricted) {
        return Left('Permission to access contacts is denied.');
      }
      // If the permission status is unknown, return an error message (Left)
      else {
        return Left('Unknown permission status.');
      }
    } catch (e) {
      // If an error occurs while checking permission, return the error message (Left)
      return Left('Error checking permission: $e');
    }
  }

// Method to request permission to access contacts
  Future<Either<String, bool>> _requestContactPermission() async {
    try {
      // Request the contacts permission
      final PermissionStatus status = await Permission.contacts.request();

      // If permission is granted, return success (Right)
      if (status.isGranted) {
        return Right(true);
      }
      // If permission is denied or restricted, return an error message (Left)
      else if (status.isDenied || status.isRestricted) {
        return Left('Permission to access contacts was denied.');
      }
      // If the permission status is unknown, return an error message (Left)
      else {
        return Left('Unknown permission status.');
      }
    } catch (e) {
      // If an error occurs while requesting permission, return the error message (Left)
      return Left('Error requesting permission: $e');
    }
  }

  // Method to fetch registered contacts from Firebase based on a list of local contacts
  Future<Either<String, List<ContactModel>>> _getRegisteredContacts(
      List<ContactModel> contacts) async {
    try {
      // Reference to the Firebase callable function 'request_registered_contacts'
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('request_registered_contacts');

      // Prepare the body of the request, converting each contact to a map
      final Map<String, List<Map<String, dynamic>>> body = {
        'contacts': contacts
            .map((c) => c.toMap())
            .toList() // Convert ContactModel to Map
      };

      // Make the call to Firebase to fetch registered contacts
      final HttpsCallableResult response = await callable.call(body);

      // Extract the data from the response
      final data = response.data;

      // Map the received 'registeredContacts' data to a list of ContactModel objects
      final List<ContactModel> registeredContacts =
          (data['registeredContacts'] as List)
              .map((contact) => ContactModel.fromJson(contact))
              .toList();

      // Return the registered contacts wrapped in Right (success)
      return Right(registeredContacts);
    } catch (e) {
      // If an error occurs, handle the exception and return the error message wrapped in Left (failure)
      final message = _cloudFunctionsErrorUtil.handleException(e);
      return Left(message);
    }
  }

  // Asynchronous function to load contacts with error handling
  Future<Either<String, List<ContactModel>>> loadContacts() async {
    try {
      // Request contact permission and handle the result
      final Either<String, bool> permissionResult =
          await _requestContactPermission();

      // Handle the permission result using `fold`
      return await permissionResult.fold(
        // If there's an error in permission request, return Left with the error message
        (error) async => Left(error),

        // If permission is granted, proceed to fetch local contacts
        (success) async {
          // Fetch local contacts and handle the result
          final Either<String, List<flutter_contacts.Contact>> localResult =
              await _fetchLocalContacts();

          // Handle the local contacts result using `fold`
          return await localResult.fold(
            // If there's an error in fetching local contacts, return Left with the error message
            (error) async => Left(error),

            // If local contacts are fetched successfully, map them to the model
            (contactsRaw) async {
              // Map raw contact data to ContactModel
              final List<ContactModel> contacts = contactsRaw
                  .map((contact) => ContactModel.fromContact(contact))
                  .toList();

              // If there are no contacts, return an empty list in Right
              if (contacts.isEmpty) {
                return Right([]);
              } else {
                // If contacts exist, proceed to check if they are registered
                return await _getRegisteredContacts(contacts);
              }
            },
          );
        },
      );
    } catch (e) {
      // Catch any unexpected errors and return Left with the error message
      return Left(e.toString());
    }
  }
}
