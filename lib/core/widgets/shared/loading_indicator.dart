import 'package:flutter/material.dart';

class TubongeLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final StrokeCap strokeCap;

  const TubongeLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeCap = StrokeCap.round,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeCap: strokeCap,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
