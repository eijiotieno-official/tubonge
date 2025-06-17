import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../src/contact/model/base/contact_model.dart';

class ReceivedMessage {
  final String senderId;
  final String senderName;
  final String senderPhoneNumber;
  final String senderPhoto;
  final String receiverId;
  final String messageId;
  final String text;

  ReceivedMessage({
    required this.senderId,
    required this.senderName,
    required this.senderPhoneNumber,
    required this.senderPhoto,
    required this.receiverId,
    required this.messageId,
    required this.text,
  });

  factory ReceivedMessage.fromRemoteMessage(
      {required RemoteMessage message, required List<ContactModel> contacts}) {
    final data = message.data;

    final processed = ReceivedMessage(
        senderId: data['sender_id'],
        senderName: data['sender_phoneNumber'],
        senderPhoneNumber: data['sender_phoneNumber'],
        senderPhoto: data['sender_photo'],
        receiverId: data['receiver_id'],
        messageId: data['message_id'],
        text: data['message_text']);

    final matchingContact = contacts
        .firstWhereOrNull((contact) => contact.id == processed.senderId);

    if (matchingContact != null) {
      processed.copyWith(senderName: matchingContact.name);
    }

    return processed;
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
      'senderPhoto': senderPhoto,
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
      senderPhoto: payload['senderPhoto'] ?? '',
      receiverId: payload['receiverId'] ?? '',
      messageId: payload['messageId'] ?? '',
      text: payload['text'] ?? '',
    );
  }

  static ReceivedMessage get empty => ReceivedMessage(
      senderId: "",
      senderName: "",
      senderPhoneNumber: "",
      senderPhoto: "",
      receiverId: "",
      messageId: "",
      text: "");
}
