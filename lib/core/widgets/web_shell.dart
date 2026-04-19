
import 'package:flutter/material.dart';

/// Web shell wrapper — currently a pass-through.
/// Will be used for persistent web navigation in the future.
class WebShell extends StatelessWidget {
  final Widget child;

  const WebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // For now, just pass through the child
    return child;
  }
}
