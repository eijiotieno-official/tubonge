import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarView extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AvatarView({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40.0,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final defaultTextColor = textColor ?? theme.colorScheme.onPrimary;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: _buildContent(context, defaultTextColor),
    );

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context, textColor),
          errorWidget: (context, url, error) =>
              _buildPlaceholder(context, textColor),
        ),
      );
    }

    return _buildPlaceholder(context, textColor);
  }

  Widget _buildPlaceholder(BuildContext context, Color textColor) {
    if (name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(
      Icons.person,
      color: textColor,
      size: size * 0.6,
    );
  }

  String _getInitials(String name) {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
