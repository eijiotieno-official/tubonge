import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../src/contact/model/base/contact_model.dart';

class ReceivedMessage {
  final String senderId;
  final String senderName;
  final String senderPhoneNumber;
  final String? senderPhoto;
  final String receiverId;
  final String messageId;
  final String text;

  ReceivedMessage({
    required this.senderId,
    required this.senderName,
    required this.senderPhoneNumber,
    this.senderPhoto,
    required this.receiverId,
    required this.messageId,
    required this.text,
  });

  factory ReceivedMessage.fromRemoteMessage(
      {required RemoteMessage message, required List<ContactModel> contacts}) {
    final dataString = message.data["data"];
    Map<String, dynamic> data;

    if (dataString is String) {
      // Handle Python-style dictionary string
      data = _parsePythonDict(dataString);
    } else {
      data = dataString as Map<String, dynamic>;
    }

    final processed = ReceivedMessage(
        senderId: data['sender_id'] ?? '',
        senderName: data['sender_phoneNumber'] ?? '',
        senderPhoneNumber: data['sender_phoneNumber'] ?? '',
        senderPhoto: data['sender_photo'] == 'None' ||
                data['sender_photo'] == null ||
                data['sender_photo'] == ''
            ? null
            : data['sender_photo'],
        receiverId: data['receiver_id'] ?? '',
        messageId: data['message_id'] ?? '',
        text: data['message_text'] ?? '');

    final matchingContact = contacts
        .firstWhereOrNull((contact) => contact.id == processed.senderId);

    if (matchingContact != null) {
      return processed.copyWith(senderName: matchingContact.name);
    }

    return processed;
  }

  static Map<String, dynamic> _parsePythonDict(String input) {
    // Remove outer braces
    String content = input.trim();
    if (content.startsWith('{') && content.endsWith('}')) {
      content = content.substring(1, content.length - 1);
    }

    Map<String, dynamic> result = {};

    // Split by comma, but be careful about commas inside quotes
    List<String> pairs = [];
    int braceCount = 0;
    int quoteCount = 0;
    int start = 0;

    for (int i = 0; i < content.length; i++) {
      if (content[i] == "'" && (i == 0 || content[i - 1] != '\\')) {
        quoteCount++;
      } else if (content[i] == '{') {
        braceCount++;
      } else if (content[i] == '}') {
        braceCount--;
      } else if (content[i] == ',' && braceCount == 0 && quoteCount % 2 == 0) {
        pairs.add(content.substring(start, i).trim());
        start = i + 1;
      }
    }
    pairs.add(content.substring(start).trim());

    for (String pair in pairs) {
      if (pair.isEmpty) continue;

      int colonIndex = pair.indexOf(':');
      if (colonIndex != -1) {
        String key = pair.substring(0, colonIndex).trim();
        String value = pair.substring(colonIndex + 1).trim();

        // Remove quotes from key and value
        if (key.startsWith("'") && key.endsWith("'")) {
          key = key.substring(1, key.length - 1);
        }

        if (value.startsWith("'") && value.endsWith("'")) {
          value = value.substring(1, value.length - 1);
        }

        result[key] = value;
      }
    }

    return result;
  }

  ReceivedMessage copyWith({
    String? senderId,
    String? senderName,
    String? senderPhoneNumber,
    String? senderPhoto,
    String? receiverId,
    String? messageId,
    String? text,
  }) {
    return ReceivedMessage(
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoneNumber: senderPhoneNumber ?? this.senderPhoneNumber,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      receiverId: receiverId ?? this.receiverId,
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
    );
  }

  Map<String, String> toPayload() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoneNumber': senderPhoneNumber,
      'senderPhoto': senderPhoto ?? '',
      'receiverId': receiverId,
      'messageId': messageId,
      'text': text,
    };
  }

  factory ReceivedMessage.fromPayload(Map<String, String?>? payload) {
    if (payload == null) return ReceivedMessage.empty;

    return ReceivedMessage(
      senderId: payload['senderId'] ?? '',
      senderName: payload['senderName'] ?? '',
      senderPhoneNumber: payload['senderPhoneNumber'] ?? '',
      senderPhoto: payload['senderPhoto'],
      receiverId: payload['receiverId'] ?? '',
      messageId: payload['messageId'] ?? '',
      text: payload['text'] ?? '',
    );
  }

  static ReceivedMessage get empty => ReceivedMessage(
      senderId: "",
      senderName: "",
      senderPhoneNumber: "",
      senderPhoto: null,
      receiverId: "",
      messageId: "",
      text: "");
}
