import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'message_model.dart';

class Chat {
  final String userId;
  List<Message> messages;
  Chat({
    required this.userId,
    required this.messages,
  });

  Chat copyWith({
    String? userId,
    List<Message>? messages,
  }) {
    return Chat(
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      userId: map['userId'] ?? '',
      messages:
          List<Message>.from(map['messages']?.map((x) => Message.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) => Chat.fromMap(json.decode(source));

  @override
  String toString() => 'Chat(userId: $userId, messages: $messages)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.userId == userId &&
        listEquals(other.messages, messages);
  }

  @override
  int get hashCode => userId.hashCode ^ messages.hashCode;
}
