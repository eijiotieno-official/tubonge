abstract class BaseModel {
  Map<String, dynamic> toMap();

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && toString() == other.toString();
  }

  @override
  int get hashCode => toString().hashCode;
}

mixin TimestampedModel {
  DateTime get createdAt;
  DateTime? get updatedAt;
}

mixin IdentifiableModel {
  String get id;
}
