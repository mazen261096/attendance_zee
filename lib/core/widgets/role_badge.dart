import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/enums.dart';

class RoleBadge extends StatelessWidget {
  final MemberRole role;
  final bool small;

  const RoleBadge({
    super.key,
    required this.role,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == MemberRole.admin;
    final color = isAdmin ? AppConfig.primaryColor : AppConfig.accentColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(small ? 6 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Student',
        style: TextStyle(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
