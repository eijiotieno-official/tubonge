import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarView extends StatelessWidget {
  final String? imageUrl;
  final double? radius;
  const AvatarView({
    super.key,
    this.imageUrl,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          imageUrl == null ? null : CachedNetworkImageProvider(imageUrl ?? ""),
      child: imageUrl == null ? Icon(Icons.person_2_rounded) : null,
    );
  }
}
