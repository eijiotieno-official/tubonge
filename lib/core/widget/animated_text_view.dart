import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final TextAlign textAlign;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    return AnimatedDefaultTextStyle(
      duration: duration,
      style: defaultStyle,
      curve: curve,
      child: Text(
        text,
        textAlign: textAlign,
      ),
    );
  }
}
