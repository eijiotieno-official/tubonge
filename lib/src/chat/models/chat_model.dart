import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'message_model.dart';

class Chat {
  final String chatId;
  List<Message> messages;
  Chat({
    required this.chatId,
    required this.messages,
  });

  Chat copyWith({
    String? chatId,
    List<Message>? messages,
  }) {
    return Chat(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatId: map['chatId'] ?? '',
      messages:
          List<Message>.from(map['messages']?.map((x) => Message.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) => Chat.fromMap(json.decode(source));

  @override
  String toString() => 'Chat(chatId: $chatId, messages: $messages)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.chatId == chatId &&
        listEquals(other.messages, messages);
  }

  @override
  int get hashCode => chatId.hashCode ^ messages.hashCode;
}
