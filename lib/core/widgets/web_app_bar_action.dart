import 'package:flutter/material.dart';

import '../utils/adaptive_manager.dart';

/// AppBar action button for web layout.
/// Shows an icon with an optional badge. Labels are visible on wide viewports
/// and hidden (icon-only) on narrow ones. Tooltip always shows the label.
class WebAppBarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  const WebAppBarAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hideLabel = AdaptiveManager.isNarrowWeb(context);

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
                child: Icon(icon, size: 22),
              ),
              if (!hideLabel) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
