import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/views/async_view.dart';
import '../../chat/screens/chat_detail_screen.dart';
import '../models/contact_model.dart';
import '../providers/contacts_provider.dart';
import '../views/contacts_list_view.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(contactsProvider.notifier).refresh();
  }

  void _onContactTap(ContactModel contact) {
    if (contact.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatDetailScreen(chatId: contact.id ?? "");
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ContactModel>> contactsValue = ref.watch(contactsProvider);

    return AsyncView(
      asyncValue: contactsValue,
      builder: (data) {
        final contacts = _searchQuery.isEmpty
            ? data
            : data
                .where((contact) => contact.name
                    .toLowerCase()
                    .trim()
                    .contains(_searchQuery.toLowerCase().trim()))
                .toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            title: TextField(
              autofocus: true,
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          body: ContactsListView(
            contacts: contacts,
            onRefresh: _onRefresh,
            onContactTap: _onContactTap,
          ),
        );
      },
    );
  }
}
