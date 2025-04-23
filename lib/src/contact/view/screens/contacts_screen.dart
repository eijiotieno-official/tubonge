import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/async_view.dart';
import '../../../chat/view/screens/chat_detail_screen.dart';
import '../../model/base/contact_model.dart';
import '../../view_model/contacts_view_model.dart';
import '../widgets/contacts_list_view.dart';

/// A screen that displays the user's contacts with search and refresh functionality.
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  // Controller for managing the search input text
  final TextEditingController _searchController = TextEditingController();

  // Current search query entered by the user
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose(); // Clean up controller on dispose
    super.dispose();
  }

  /// Called when the user pulls to refresh the contact list.
  Future<void> _onRefresh() async {
    await ref.read(contactsProvider.notifier).refresh();
  }

  /// Called when a contact is tapped.
  /// Navigates to the [ChatDetailScreen] if the contact has a valid ID.
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
    // Watch the contacts provider to get the async list of contacts
    final AsyncValue<List<ContactModel>> contactsValue =
        ref.watch(contactsProvider);

    return AsyncView(
      asyncValue: contactsValue,
      builder: (data) {
        // If there's a search query, filter the contacts accordingly
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
            // Search input field in the AppBar
            title: TextField(
              autofocus: true,
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim(); // Update the search query
                });
              },
            ),
          ),
          // Display the contact list or empty state with pull-to-refresh
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
