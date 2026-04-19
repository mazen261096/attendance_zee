import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Reusable profile avatar with cached network image support.
/// Handles null/empty URLs, loading, errors, and anonymous states.
class ProfileAvatar extends StatelessWidget {
  /// Image URL to display (nullable for missing/anonymous users)
  final String? imageUrl;

  /// Name for fallback initials (uses first letter)
  final String? name;

  /// Diameter of the avatar
  final double size;

  /// Whether to show anonymous (?) icon
  final bool isAnonymous;

  /// Background color for fallback avatar
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.isAnonymous = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = theme.colorScheme.onPrimaryContainer;

    // Anonymous user - show question mark icon
    if (isAnonymous) {
      return _buildFallbackAvatar(
        child: Icon(
          Icons.help_outline_rounded,
          color: fgColor,
          size: size * 0.5,
        ),
        bgColor: bgColor,
      );
    }

    // No image URL - show initials or person icon
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(
        child: name != null && name!.isNotEmpty
            ? Text(
                name![0].toUpperCase(),
                style: TextStyle(
                  color: fgColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(Icons.person_rounded, color: fgColor, size: size * 0.5),
        bgColor: bgColor,
      );
    }

    // Has image URL - show cached network image
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildFallbackAvatar(
          child: SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
          ),
          bgColor: bgColor,
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(
          child: Icon(Icons.person_rounded, color: fgColor, size: size * 0.5),
          bgColor: bgColor,
        ),
        errorListener: (error) {
          // Suppress the large stack trace for expected missing avatars (400/404)
          debugPrint('Avatar not found or invalid: $imageUrl');
        },
      ),
    );
  }

  Widget _buildFallbackAvatar({required Widget child, required Color bgColor}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}
