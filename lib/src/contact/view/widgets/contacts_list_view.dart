import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import '../../model/base/contact_model.dart';
import 'contact_view.dart';

/// A scrollable list of contacts with pull-to-refresh functionality.
/// Displays each contact using the [ContactView] widget.
class ContactsListView extends StatelessWidget {
  /// List of contacts to be displayed.
  final List<ContactModel> contacts;

  /// Callback triggered when the user performs a pull-to-refresh gesture.
  final Future<void> Function() onRefresh;

  /// Callback when a contact is tapped.
  final ValueChanged<ContactModel> onContactTap;

  const ContactsListView({
    super.key,
    required this.contacts,
    required this.onRefresh,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      // Trigger the provided refresh callback
      onRefresh: onRefresh,

      // Custom indicator builder
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                child, // The list or empty state content below
                if (controller.value > 0)
                  Opacity(
                    opacity: controller.value,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: const CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },

      // The main child content of the scroll view
      child: contacts.isEmpty
          ? const Center(child: Text("No contacts available")) // Empty state
          : ListView.builder(
              physics: BouncingScrollPhysics(), // Smooth iOS-style scroll
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactView(
                  contact: contact,
                  onContactTap: onContactTap,
                );
              },
            ),
    );
  }
}
