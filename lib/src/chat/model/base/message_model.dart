import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  none;

  String toMap() {
    return name;
  }

  static MessageType fromMap(String string) {
    try {
      return MessageType.values
          .firstWhere((MessageType test) => test.name == string);
    } catch (e) {
      throw Exception("Unknown MessageType: $string");
    }
  }
}

enum MessageStatus {
  sent,
  delivered,
  seen,
  none;

  String toMap() {
    return name;
  }

  static MessageStatus fromMap(String string) {
    try {
      return MessageStatus.values
          .firstWhere((MessageStatus test) => test.name == string);
    } catch (e) {
      throw Exception("Unknown MessageStatus: $string");
    }
  }
}

abstract class Message {
  final String id;
  final String sender;
  final String receiver;
  final MessageType type;
  final MessageStatus status;
  final DateTime timeSent;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.status,
    required this.timeSent,
  });

  Message copyWith({
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  });

  Map<String, dynamic> toMap();

  static Message fromMap(Map<String, dynamic> map) {
    final messageType = MessageType.fromMap(map["type"]);

    switch (messageType) {
      case MessageType.text:
        return TextMessage.fromMap(map);
      default:
        throw Exception('Unknown MessageType: $messageType');
    }
  }

  static Message? empty(MessageType type) {
    switch (type) {
      case MessageType.text:
        return TextMessage(
          text: "",
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime(2024, 1, 1),
        );
      case MessageType.none:
        return null;
    }
  }
}

class TextMessage extends Message {
  final String text;

  TextMessage({
    required this.text,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.text);

  @override
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': status.toMap(),
      'type': type.toMap(),
      'timeSent': FieldValue.serverTimestamp(),
    };
  }

  static TextMessage fromMap(Map<String, dynamic> map) {
    DateTime timeSent;
    if (map['timeSent'] == null) {
      timeSent = DateTime.now();
    } else if (map['timeSent'] is Timestamp) {
      timeSent = map['timeSent'].toDate();
    } else {
      timeSent = DateTime.now();
    }

    return TextMessage(
      text: map['text'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatus.fromMap(map['status']),
      timeSent: timeSent,
    );
  }

  @override
  TextMessage copyWith({
    String? text,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return TextMessage(
      text: text ?? this.text,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static TextMessage get empty => TextMessage(
        text: "",
        id: "",
        sender: "",
        receiver: "",
        status: MessageStatus.none,
        timeSent: DateTime(2024, 1, 1),
      );

  bool isNotEmpty() {
    return text.isNotEmpty && sender.isNotEmpty && receiver.isNotEmpty;
  }

  @override
  String toString() => 'TextMessage(text: $text, timeSent: $timeSent)';
}
