import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'phone_model.dart';

class UserModel {
  final String id;
  final PhoneModel phone;
  final String? photo;
  final List<String> tokens;

  UserModel({
    required this.id,
    required this.phone,
    this.photo,
    required this.tokens,
  });

  static UserModel get empty => UserModel(
        id: '',
        phone: PhoneModel.empty(),
        photo: null,
        tokens: [],
      );

  UserModel copyWith({
    String? id,
    PhoneModel? phone,
    String? photo,
    List<String>? tokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      tokens: tokens ?? this.tokens,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone.toMap(),
      'photo': photo,
      'tokens': tokens,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      phone: PhoneModel.fromMap(map['phone']),
      photo: map['photo'],
      tokens: List<String>.from(map['tokens']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(id: $id, phone: $phone, photo: $photo, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.phone == phone &&
        other.photo == photo &&
        listEquals(other.tokens, tokens);
  }

  @override
  int get hashCode {
    return id.hashCode ^ phone.hashCode ^ photo.hashCode ^ tokens.hashCode;
  }
}
