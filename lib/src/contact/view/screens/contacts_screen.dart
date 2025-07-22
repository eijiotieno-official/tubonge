import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/async_view.dart';
import '../../../chat/view/screens/chat_detail_screen.dart';
import '../../model/base/contact_model.dart';
import '../../view_model/contacts_view_model.dart';
import '../widgets/contacts_list_view.dart';

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
    final AsyncValue<List<ContactModel>> contactsValue =
        ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: TextField(
          autofocus: true,
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search contact...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            elevation: 1,
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'refresh') {
                _onRefresh();
              }
            },
            borderRadius: BorderRadius.circular(16.0),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Text('Refresh'),
                ),
              ];
            },
          ),
        ],
      ),
      body: AsyncView(
          asyncValue: contactsValue,
          errorBuilder: (error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  Text(error.toString()),
                  TextButton(
                    onPressed: _onRefresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          },
          builder: (data) {
            List<ContactModel> contacts = _searchQuery.isEmpty
                ? data
                : data
                    .where((contact) => contact.name
                        .toLowerCase()
                        .trim()
                        .contains(_searchQuery.toLowerCase().trim()))
                    .toList();

            return ContactsListView(
              contacts: contacts,
              onRefresh: _onRefresh,
              onContactTap: _onContactTap,
            );
          }),
    );
  }
}
