import 'dart:convert';

class Profile {
  final String id;
  final String name;
  final String photoUrl;
  Profile({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  

  Profile copyWith({
    String? id,
    String? name,
    String? photoUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) => Profile.fromMap(json.decode(source));

  @override
  String toString() => 'Profile(id: $id, name: $name, photoUrl: $photoUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Profile &&
      other.id == id &&
      other.name == name &&
      other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ photoUrl.hashCode;
}
