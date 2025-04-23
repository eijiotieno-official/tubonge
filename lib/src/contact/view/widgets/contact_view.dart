import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/avatar_view.dart';
import '../../model/base/contact_model.dart';

/// A widget that displays an individual contact in a list,
/// showing their avatar and name, and notifies when tapped.
class ContactView extends ConsumerWidget {
  /// The contact data to render (name, photo URL, id, etc.).
  final ContactModel contact;

  /// Callback invoked when the user taps this contact tile.
  final ValueChanged<ContactModel> onContactTap;

  const ContactView({
    super.key,
    required this.contact,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      // Trigger the provided callback, passing in this contact
      onTap: () => onContactTap(contact),

      // Leading avatar view showing the contact's photo (or placeholder)
      leading: AvatarView(imageUrl: contact.photo),

      // Main title displaying the contact's display name
      title: Text(contact.name),
    );
  }
}
