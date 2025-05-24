import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
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
                child,
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
      child: contacts.isEmpty
          ? const Center(child: Text("No contacts available"))
          : ListView.builder(
              physics: BouncingScrollPhysics(),
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
