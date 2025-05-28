import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

import 'loading_indicator.dart';

class TubongeListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onRefresh;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? separator;
  final Widget? header;
  final Widget? footer;

  const TubongeListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyWidget,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.separator,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: emptyWidget ?? const Text('No items available'),
      );
    }

    Widget listView = ListView.separated(
      controller: controller,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount:
          items.length + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
      separatorBuilder: (context, index) {
        if (header != null && index == 0) return const SizedBox.shrink();
        if (footer != null && index == items.length)
          return const SizedBox.shrink();
        return separator ?? const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        if (footer != null &&
            index == items.length + (header != null ? 1 : 0)) {
          return footer!;
        }
        final itemIndex = index - (header != null ? 1 : 0);
        return itemBuilder(context, items[itemIndex], itemIndex);
      },
    );

    if (onRefresh != null) {
      listView = CustomRefreshIndicator(
        onRefresh: onRefresh!,
        builder: (
          BuildContext context,
          Widget child,
          IndicatorController controller,
        ) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              child,
              if (controller.value > 0)
                Opacity(
                  opacity: controller.value,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: TubongeLoadingIndicator(
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
            ],
          );
        },
        child: listView,
      );
    }

    return listView;
  }
}
