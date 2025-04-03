import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/avatar_view.dart';
import '../../model/base/contact_model.dart';

class ContactView extends ConsumerWidget {
  final ContactModel contact;
  final ValueChanged<ContactModel> onContactTap;
  const ContactView({
    super.key,
    required this.contact,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => onContactTap(contact),
      leading: AvatarView(imageUrl: contact.photo),
      title: Text(contact.name),
    );
  }
}
