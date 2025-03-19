import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/message_model.dart';

class SelectedMessages {
  final String chatId;
  final List<Message> messages;
  SelectedMessages({
    required this.chatId,
    required this.messages,
  });

  SelectedMessages copyWith({
    String? chatId,
    List<Message>? messages,
  }) {
    return SelectedMessages(
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
    );
  }
}

class SelectedMessagesNotifier extends StateNotifier<List<SelectedMessages>> {
  SelectedMessagesNotifier() : super([]);

  void _addMessage({
    required String chatId,
    required Message message,
  }) {
    state = state.map((selected) {
      if (selected.chatId == chatId) {
        return selected.copyWith(
          messages: [...selected.messages, message],
        );
      }
      return selected;
    }).toList();

    if (!state.any((selected) => selected.chatId == chatId)) {
      state = [
        ...state,
        SelectedMessages(chatId: chatId, messages: [message]),
      ];
    }
  }

  void _removeMessage({
    required String chatId,
    required String messageId,
  }) {
    state = state.map((selected) {
      if (selected.chatId == chatId) {
        return selected.copyWith(
          messages: selected.messages
              .where((message) => message.id != messageId)
              .toList(),
        );
      }
      return selected;
    }).toList();

    state = state.where((selected) => selected.messages.isNotEmpty).toList();
  }

  void clearChatSelection(String chatId) {
    state = state.where((selected) => selected.chatId != chatId).toList();
  }

  void clearAllSelections() {
    state = [];
  }

  List<Message> getSelectedMessages(String? chatId) {
    if (chatId == null) return [];
    return state
            .firstWhereOrNull((selected) => selected.chatId == chatId)
            ?.messages ??
        [];
  }

  bool isMessageSelected({
    required String chatId,
    required String messageId,
  }) {
    return state.any((selected) =>
        selected.chatId == chatId &&
        selected.messages.any((message) => message.id == messageId));
  }

  void select({
    required String chatId,
    required Message message,
    required bool isOnTap,
  }) {
    if (isOnTap == false) {
      if (state.isEmpty) {
        _addMessage(chatId: chatId, message: message);
      }
    } else {
      if (state.isNotEmpty) {
        bool isSelected =
            isMessageSelected(chatId: chatId, messageId: message.id);

        if (isSelected) {
          _removeMessage(chatId: chatId, messageId: message.id);
        } else {
          _addMessage(chatId: chatId, message: message);
        }
      }
    }
  }
}

final selectedMessagesProvider =
    StateNotifierProvider<SelectedMessagesNotifier, List<SelectedMessages>>(
  (ref) => SelectedMessagesNotifier(),
);
