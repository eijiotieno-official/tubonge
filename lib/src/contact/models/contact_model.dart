import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/contact.dart' as flutter_contacts;
import '../../../core/models/phone_model.dart';

class ContactModel {
  final String name;
  final List<PhoneModel> phoneNumbers;
  final String? id;
  final String? photo;

  ContactModel({
    required this.name,
    required this.phoneNumbers,
    this.id,
    this.photo,
  });

  factory ContactModel.fromContact(flutter_contacts.Contact contact) {
    return ContactModel(
      name: contact.name.first,
      phoneNumbers: contact.phones
          .map(
            (phone) => PhoneModel(
              isoCode: "",
              dialCode: "",
              phoneNumber: phone.number,
            ),
          )
          .toList(),
    );
  }

  ContactModel copyWith({
    String? name,
    List<PhoneModel>? phoneNumbers,
    String? id,
    String? photo,
  }) {
    return ContactModel(
      name: name ?? this.name,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      id: id ?? this.id,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumbers': phoneNumbers.map((x) => x.toMap()).toList(),
      'id': id,
      'photo': photo,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      name: map['name'] ?? '',
      phoneNumbers: List<PhoneModel>.from(
          map['phoneNumbers']?.map((x) => PhoneModel.fromMap(x))),
      id: map['id'],
      photo: map['photo'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ContactModel.fromJson(String source) =>
      ContactModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ContactModel(name: $name, phoneNumbers: $phoneNumbers, id: $id, photo: $photo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ContactModel &&
        other.name == name &&
        listEquals(other.phoneNumbers, phoneNumbers) &&
        other.id == id &&
        other.photo == photo;
  }

  @override
  int get hashCode {
    return name.hashCode ^ phoneNumbers.hashCode ^ id.hashCode ^ photo.hashCode;
  }

  static ContactModel empty() => ContactModel(
        name: "",
        phoneNumbers: [],
      );
}
