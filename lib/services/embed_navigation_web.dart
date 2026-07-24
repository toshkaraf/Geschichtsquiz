// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:flutter/material.dart';

/// Web: coordinate back with parent page when running inside an iframe.
class EmbedNavigation {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    if (!isEmbedded) return;
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is! Map) return;
      final type = data['type'];
      if (type == 'HISTORY_QUIZ_BACK') {
        handleParentBackRequest();
      }
    });
  }

  static bool get isEmbedded {
    try {
      return html.window.parent != null && html.window.parent != html.window;
    } catch (_) {
      return false;
    }
  }

  static void _postToParent(Map<String, String> payload) {
    if (!isEmbedded) return;
    html.window.parent?.postMessage(payload, html.window.location.origin);
  }

  static void handleParentBackRequest() {
    tryPopOrRequestExit();
  }

  static bool tryPopOrRequestExit() {
    final nav = navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    if (isEmbedded) {
      _postToParent({'type': 'HISTORY_QUIZ_EXIT'});
      return true;
    }
    return false;
  }
}
