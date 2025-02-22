import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../provider/drawer_provider.dart';

class SearchBarView extends ConsumerWidget {
  const SearchBarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DeviceScreenType screenType = getDeviceType(MediaQuery.of(context).size);

    final padding = getValueForScreenType<double>(
      context: context,
      mobile: 8,
      tablet: 16,
      desktop: 16,
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: SizedBox(
        width: double.infinity,
        child: SearchAnchor(
          viewElevation: 1,
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              elevation: WidgetStatePropertyAll(0),
              controller: controller,
              leading: _buildLeadingIcon(screenType, ref, controller),
              onTap: () => controller.openView(),
              hintText: "Search Gmail",
            );
          },
          suggestionsBuilder: (context, controller) {
            return [];
          },
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(
      DeviceScreenType screenType, WidgetRef ref, SearchController controller) {
    return screenType == DeviceScreenType.mobile
        ? IconButton(
            onPressed: () {
              ref.read(drawerProvider.notifier).openDrawer();
            },
            icon: const Icon(Icons.menu_rounded),
          )
        : IconButton(
            onPressed: () => controller.openView(),
            icon: const Icon(Icons.search_rounded),
          );
  }
}
