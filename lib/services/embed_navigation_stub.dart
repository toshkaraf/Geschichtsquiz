import 'package:flutter/material.dart';

/// Non-web: no parent iframe integration.
class EmbedNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void init() {}

  static bool get isEmbedded => false;

  static void handleParentBackRequest() {}

  static bool tryPopOrRequestExit() {
    final nav = navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return false;
  }
}
