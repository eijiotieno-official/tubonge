import 'dart:convert';

class AuthUser {
  final String id;
  final String email;
  AuthUser({
    required this.id,
    required this.email,
  });

  AuthUser copyWith({
    String? id,
    String? email,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthUser.fromJson(String source) =>
      AuthUser.fromMap(json.decode(source));

  @override
  String toString() => 'AuthUser(id: $id, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthUser && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  static AuthUser empty() => AuthUser(
        id: "",
        email: "",
      );
}
