import 'package:flutter/material.dart';

import '../../../../core/widgets/shared/tubonge_list_view.dart';
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
    return TubongeListView<ContactModel>(
      items: contacts,
      onRefresh: onRefresh,
      itemBuilder: (context, contact, index) {
        return ContactView(
          contact: contact,
          onContactTap: onContactTap,
        );
      },
      emptyWidget: const Center(
        child: Text('No contacts available'),
      ),
      physics: const BouncingScrollPhysics(),
    );
  }
}
