import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/routes.dart';

/// Adaptive scaffold that handles mobile vs web differences.
///
/// - On **mobile**: wraps [body] in a [Scaffold] with [mobileAppBar].
///   Also handles back navigation: if the navigator can't pop (e.g. deep link
///   entry), redirects to the home screen instead of closing the app.
/// - On **web**: returns [body] directly — the persistent [WebShell]
///   (via ShellRoute) already provides the Scaffold and app bar.
class WebScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? mobileAppBar;

  const WebScaffold({super.key, required this.body, this.mobileAppBar});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return body;
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            // Deep link entry — go to home instead of closing the app
            router.go(Routes.home);
          }
        }
      },
      child: Scaffold(appBar: mobileAppBar, body: body),
    );
  }
}
