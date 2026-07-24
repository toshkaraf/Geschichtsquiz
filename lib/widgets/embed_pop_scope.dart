import 'package:flutter/material.dart';

import '../services/embed_navigation.dart';

/// System / gesture back: pop route stack first; in iframe at root, ask parent to leave.
class EmbedPopScope extends StatelessWidget {
  final Widget child;

  const EmbedPopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        EmbedNavigation.tryPopOrRequestExit();
      },
      child: child,
    );
  }
}
