import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../resources/app_strings.dart';
import '../services/connectivity_service.dart';

/// A small animated banner that slides in from the top when offline.
/// Wraps any child widget and overlays the banner above it.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, _) {
        final isOffline = !ConnectivityService.instance.isConnected;

        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isOffline
                  ? Material(
                      color: Colors.red.shade700,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.noInternetConnection.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: isOffline
                  ? MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: child,
                    )
                  : child,
            ),
          ],
        );
      },
    );
  }
}
