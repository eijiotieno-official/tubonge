import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

final selectedIndexProvider = StateProvider<int>(
  (ref) {
    return 0;
  },
);

class RailView extends ConsumerWidget {
  const RailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenType = getDeviceType(MediaQuery.of(context).size);

    final shouldHide = screenType == DeviceScreenType.mobile;

    final selectedIndex = ref.watch(selectedIndexProvider);

    return shouldHide
        ? SizedBox.shrink()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  getValueForScreenType<double>(
                    context: context,
                    mobile: 8,
                    tablet: 16,
                    desktop: 16,
                  ),
                ),
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {},
                  child: Icon(Icons.create_rounded),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      onDestinationSelected: (index) {
                        ref.read(selectedIndexProvider.notifier).state = index;
                      },
                      extended: screenType == DeviceScreenType.desktop,
                      destinations: _buildNavigationRailDestinations(context),
                      selectedIndex: selectedIndex,
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  List<NavigationRailDestination> _buildNavigationRailDestinations(
      BuildContext context) {
    final destinations = [
      _navigationRailDestination(
        icon: Icons.chat_bubble_outline_rounded,
        selectedIcon: Icons.chat_bubble,
        label: "Chat",
        unreadCount: 0,
        context: context,
      ),
      _navigationRailDestination(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: "Settings",
        unreadCount: 0,
        context: context,
      ),
    ];

    return destinations;
  }

  /// Builds a single navigation rail destination with a badge for unread count.
  NavigationRailDestination _navigationRailDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int unreadCount,
    required BuildContext context,
  }) {
    return NavigationRailDestination(
      padding: EdgeInsets.zero,
      icon: Badge.count(
        isLabelVisible: unreadCount > 0,
        count: unreadCount,
        child: Icon(icon),
      ),
      selectedIcon: Badge.count(
        isLabelVisible: unreadCount > 0,
        count: unreadCount,
        child: Icon(selectedIcon),
      ),
      label: Text(label),
    );
  }
}
