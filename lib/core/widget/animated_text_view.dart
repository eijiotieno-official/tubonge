import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final TextAlign textAlign;
  final bool isTitle;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.textAlign = TextAlign.start,
    this.isTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headlineFontSize = constraints.maxWidth < 300
            ? 20.0
            : constraints.maxWidth > 600
                ? 28.0
                : lerpDouble(20, 28, (constraints.maxWidth - 300) / 300)!;

        final labelFontSize = constraints.maxWidth < 300
            ? 14.0
            : constraints.maxWidth > 600
                ? 16.0
                : lerpDouble(14, 16, (constraints.maxWidth - 300) / 300)!;

        final defaultStyle = style ??
            DefaultTextStyle.of(context).style.copyWith(
                  fontSize: isTitle ? headlineFontSize : labelFontSize,
                  fontWeight: isTitle ? FontWeight.bold : null,
                );

        return AnimatedDefaultTextStyle(
          duration: duration,
          style: defaultStyle,
          curve: curve,
          child: Text(
            text,
            textAlign: textAlign,
          ),
        );
      },
    );
  }
}
