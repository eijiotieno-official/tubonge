import 'package:flutter/material.dart';

class TubongeFilledButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final String text;
  final bool isExtended;
  const TubongeFilledButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.text,
    this.isExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator(strokeCap: StrokeCap.round)
          : SizedBox(
              width: isExtended ? double.infinity : null,
              child: FilledButton(
                onPressed: onTap,
                child: Text(text),
              ),
            ),
    );
  }
}
