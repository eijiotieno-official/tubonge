enum MessageType {
  text,
  audio,
  image,
  video,
  voice,
  document,
  none,
}

extension MessageTypeExtension on MessageType {
  static String toStringValue(MessageType type) {
    try {
      return type.name;
    } catch (e) {
      throw Exception("Unknown MessageType: $type");
    }
  }

  static MessageType toTypeValue(String string) {
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
  none,
}

extension MessageStatusExtension on MessageStatus {
  static String toStringValue(MessageStatus status) {
    try {
      return status.name;
    } catch (e) {
      throw Exception("Unknown MessageStatus: $status");
    }
  }

  static MessageStatus toTypeValue(String string) {
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
    final messageType = MessageTypeExtension.toTypeValue(map["type"]);

    switch (messageType) {
      case MessageType.text:
        return TextMessage.fromMap(map);
      case MessageType.image:
        return ImageMessage.fromMap(map);
      default:
        throw Exception('Unknown MessageType: $messageType');
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
    return <String, dynamic>{
      'text': text,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.toStringValue(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.toStringValue(type),
    };
  }

  static TextMessage fromMap(Map<String, dynamic> map) {
    return TextMessage(
      text: map['text'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toTypeValue(map['status']),
      timeSent: map['timeSent'].toDate(),
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

  static TextMessage empty() {
    return TextMessage(
      text: "",
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
    );
  }

  bool isNotEmpty() {
    return text.isNotEmpty && sender.isNotEmpty && receiver.isNotEmpty;
  }

  @override
  String toString() => 'TextMessage(text: $text, timeSent: $timeSent)';
}

class ImageMessage extends Message {
  final String? text;
  final String imageUri;

  ImageMessage({
    this.text,
    required this.imageUri,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.image);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'imageUri': imageUri,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.toStringValue(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.toStringValue(type),
    };
  }

  static ImageMessage fromMap(Map<String, dynamic> map) {
    return ImageMessage(
      text: map['text'],
      imageUri: map['imageUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toTypeValue(map['status']),
      timeSent: map['timeSent'].toDate(),
    );
  }

  @override
  ImageMessage copyWith({
    String? text,
    String? imageUri,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return ImageMessage(
      text: text ?? this.text,
      imageUri: imageUri ?? this.imageUri,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static ImageMessage empty() {
    return ImageMessage(
      text: null,
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
      imageUri: "",
    );
  }

  bool isNotEmpty() {
    return imageUri.isNotEmpty && sender.isNotEmpty && receiver.isNotEmpty;
  }

  @override
  String toString() =>
      'ImageMessage(text: $text, imageUri: $imageUri, timeSent: $timeSent)';
}
