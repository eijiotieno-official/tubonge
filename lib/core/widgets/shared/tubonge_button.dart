import 'package:flutter/material.dart';

import 'loading_indicator.dart';

enum TubongeButtonVariant {
  filled,
  outlined,
  text,
}

class TubongeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExtended;
  final TubongeButtonVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;

  const TubongeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExtended = false,
    this.variant = TubongeButtonVariant.filled,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(8.0);
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isExtended ? 32.0 : 16.0,
      vertical: 12.0,
    );

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8.0),
        ],
        if (isLoading)
          const TubongeLoadingIndicator(size: 20.0)
        else
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: _getTextColor(theme),
            ),
          ),
      ],
    );

    if (width != null || height != null) {
      buttonChild = SizedBox(
        width: width,
        height: height,
        child: Center(child: buttonChild),
      );
    }

    switch (variant) {
      case TubongeButtonVariant.filled:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: textColor ?? theme.colorScheme.onPrimary,
            padding: padding ?? defaultPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? defaultBorderRadius,
            ),
          ),
          child: buttonChild,
        );

      case TubongeButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            foregroundColor: textColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: backgroundColor ?? theme.colorScheme.primary,
            ),
            padding: padding ?? defaultPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? defaultBorderRadius,
            ),
          ),
          child: buttonChild,
        );

      case TubongeButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            foregroundColor: textColor ?? theme.colorScheme.primary,
            padding: padding ?? defaultPadding,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? defaultBorderRadius,
            ),
          ),
          child: buttonChild,
        );
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (textColor != null) return textColor!;

    switch (variant) {
      case TubongeButtonVariant.filled:
        return theme.colorScheme.onPrimary;
      case TubongeButtonVariant.outlined:
      case TubongeButtonVariant.text:
        return theme.colorScheme.primary;
    }
  }
}
