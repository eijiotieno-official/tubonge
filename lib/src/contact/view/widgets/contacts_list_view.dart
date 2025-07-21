import 'package:flutter/material.dart';

import '../../model/base/contact_model.dart';
import 'contact_view.dart';

class ContactsListView extends StatelessWidget {
  final List<ContactModel> contacts;
  final Future<void> Function() onRefresh;
  final ValueChanged<ContactModel> onContactTap;

  const ContactsListView({
    super.key,
    required this.contacts,
    required this.onRefresh,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return contacts.isEmpty
        ? const Center(
            child: Text('No contacts available'),
          )
        : ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return ContactView(
                contact: contact,
                onContactTap: onContactTap,
              );
            },
            physics: const BouncingScrollPhysics(),
          );
  }
}
