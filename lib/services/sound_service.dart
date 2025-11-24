import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    }
  }

  static Future<void> playCorrectSound() async {
    try {
      await _ensureInitialized();
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      debugPrint('Sound error (correct): $e');
      // Fallback на вибрацию
      try {
        await HapticFeedback.mediumImpact();
      } catch (e2) {
        debugPrint('Haptic feedback error: $e2');
      }
    }
  }

  static Future<void> playIncorrectSound() async {
    try {
      await _ensureInitialized();
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    } catch (e) {
      debugPrint('Sound error (incorrect): $e');
      // Fallback на вибрацию
      try {
        await HapticFeedback.lightImpact();
      } catch (e2) {
        debugPrint('Haptic feedback error: $e2');
      }
    }
  }

  static Future<void> playNewQuestionSound() async {
    try {
      await _ensureInitialized();
      await _audioPlayer.play(AssetSource('sounds/new_question.mp3'));
    } catch (e) {
      debugPrint('Sound error (new question): $e');
      // Fallback - kein Sound, nur leise
    }
  }

  static Future<void> dispose() async {
    await _audioPlayer.dispose();
    _isInitialized = false;
  }
}


