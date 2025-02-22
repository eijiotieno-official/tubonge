enum MessageStatus {
  sent,
  delivered,
  seen,
  none,
}

extension MessageStatusExtension on MessageStatus {
  static String fromType(MessageStatus status) {
    try {
      return status.name;
    } catch (e) {
      throw Exception("Unknown MessageStatus: $status");
    }
  }

  static MessageStatus toType(String string) {
    try {
      return MessageStatus.values
          .firstWhere((MessageStatus test) => test.name == string);
    } catch (e) {
      throw Exception("Unknown MessageStatus: $string");
    }
  }
}

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
  static String fromType(MessageType type) {
    try {
      return type.name;
    } catch (e) {
      throw Exception("Unknown MessageType: $type");
    }
  }

  static MessageType toType(String string) {
    try {
      return MessageType.values
          .firstWhere((MessageType test) => test.name == string);
    } catch (e) {
      throw Exception("Unknown MessageType: $string");
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
    final messageType = MessageTypeExtension.toType(map["type"]);

    switch (messageType) {
      case MessageType.text:
        return TextMessage.fromMap(map);
      case MessageType.image:
        return ImageMessage.fromMap(map);
      case MessageType.video:
        return VideoMessage.fromMap(map);
      case MessageType.voice:
        return VoiceMessage.fromMap(map);
      case MessageType.audio:
        return AudioMessage.fromMap(map);
      case MessageType.document:
        return DocumentMessage.fromMap(map);
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
          timeSent: DateTime.now(),
        );
      case MessageType.image:
        return ImageMessage(
          text: null,
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime.now(),
          imageUri: "",
        );
      case MessageType.video:
        return VideoMessage(
          text: null,
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime.now(),
          videoUri: "",
        );
      case MessageType.audio:
        return AudioMessage(
          audioTitle: "",
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime.now(),
          audioUri: "",
        );
      case MessageType.voice:
        return VoiceMessage(
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime.now(),
          voiceUri: "",
        );
      case MessageType.document:
        return DocumentMessage(
          documentTitle: "",
          id: "",
          sender: "",
          receiver: "",
          status: MessageStatus.none,
          timeSent: DateTime.now(),
          documentUri: "",
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
    return <String, dynamic>{
      'text': text,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static TextMessage fromMap(Map<String, dynamic> map) {
    return TextMessage(
      text: map['text'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
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
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static ImageMessage fromMap(Map<String, dynamic> map) {
    return ImageMessage(
      text: map['text'],
      imageUri: map['imageUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
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

class VideoMessage extends Message {
  final String? text;
  final String videoUri;

  VideoMessage({
    this.text,
    required this.videoUri,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.video);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'videoUri': videoUri,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static VideoMessage fromMap(Map<String, dynamic> map) {
    return VideoMessage(
      text: map['text'],
      videoUri: map['videoUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
      timeSent: map['timeSent'].toDate(),
    );
  }

  @override
  VideoMessage copyWith({
    String? text,
    String? videoUri,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return VideoMessage(
      text: text ?? this.text,
      videoUri: videoUri ?? this.videoUri,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static VideoMessage empty() {
    return VideoMessage(
      text: null,
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
      videoUri: "",
    );
  }

  bool isNotEmpty() {
    return videoUri.isNotEmpty && sender.isNotEmpty && receiver.isNotEmpty;
  }
}

class AudioMessage extends Message {
  final String audioTitle;
  final String audioUri;

  AudioMessage({
    required this.audioTitle,
    required this.audioUri,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.audio);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'audioTitle': audioTitle,
      'audioUri': audioUri,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static AudioMessage fromMap(Map<String, dynamic> map) {
    return AudioMessage(
      audioTitle: map['audioTitle'],
      audioUri: map['audioUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
      timeSent: map['timeSent'].toDate(),
    );
  }

  @override
  AudioMessage copyWith({
    String? audioTitle,
    String? audioUri,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return AudioMessage(
      audioTitle: audioTitle ?? this.audioTitle,
      audioUri: audioUri ?? this.audioUri,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static AudioMessage empty() {
    return AudioMessage(
      audioTitle: "",
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
      audioUri: "",
    );
  }

  bool isNotEmpty() {
    return audioTitle.isNotEmpty &&
        audioUri.isNotEmpty &&
        sender.isNotEmpty &&
        receiver.isNotEmpty;
  }
}

class VoiceMessage extends Message {
  final String voiceUri;

  VoiceMessage({
    required this.voiceUri,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.voice);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'voiceUri': voiceUri,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static VoiceMessage fromMap(Map<String, dynamic> map) {
    return VoiceMessage(
      voiceUri: map['voiceUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
      timeSent: map['timeSent'].toDate(),
    );
  }

  @override
  VoiceMessage copyWith({
    String? text,
    String? voiceUri,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return VoiceMessage(
      voiceUri: voiceUri ?? this.voiceUri,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static VoiceMessage empty() {
    return VoiceMessage(
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
      voiceUri: "",
    );
  }

  bool isNotEmpty() {
    return voiceUri.isNotEmpty && sender.isNotEmpty && receiver.isNotEmpty;
  }
}

class DocumentMessage extends Message {
  final String documentTitle;
  final String documentUri;

  DocumentMessage({
    required this.documentTitle,
    required this.documentUri,
    required super.id,
    required super.sender,
    required super.receiver,
    required super.status,
    required super.timeSent,
  }) : super(type: MessageType.document);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentTitle': documentTitle,
      'documentUri': documentUri,
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'status': MessageStatusExtension.fromType(status),
      'timeSent': timeSent,
      'type': MessageTypeExtension.fromType(type),
    };
  }

  static DocumentMessage fromMap(Map<String, dynamic> map) {
    return DocumentMessage(
      documentTitle: map['documentTitle'],
      documentUri: map['documentUri'],
      id: map['id'],
      sender: map['sender'],
      receiver: map['receiver'],
      status: MessageStatusExtension.toType(map['status']),
      timeSent: map['timeSent'].toDate(),
    );
  }

  @override
  DocumentMessage copyWith({
    String? documentTitle,
    String? documentUri,
    String? id,
    String? sender,
    String? receiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? timeSent,
  }) {
    return DocumentMessage(
      documentTitle: documentTitle ?? this.documentTitle,
      documentUri: documentUri ?? this.documentUri,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  static DocumentMessage empty() {
    return DocumentMessage(
      documentTitle: "",
      id: "",
      sender: "",
      receiver: "",
      status: MessageStatus.none,
      timeSent: DateTime.now(),
      documentUri: "",
    );
  }

  bool isNotEmpty() {
    return documentTitle.isNotEmpty &&
        documentUri.isNotEmpty &&
        sender.isNotEmpty &&
        receiver.isNotEmpty;
  }
}
