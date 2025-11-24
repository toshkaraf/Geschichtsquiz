import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SoundService {
  static const MethodChannel _channel = MethodChannel('quiz/sound');

  static Future<void> playCorrectSound() async {
    try {
      // Создаем приятную мелодию из нескольких тонов
      // Играем последовательность нот: до-ми-соль-до (мажорное трезвучие)
      // Для правильного ответа используем короткую последовательность звуков
      
      // Используем вибрацию для имитации приятной мелодии
      // Каждая вибрация имитирует один тон в последовательности
      for (int i = 0; i < 4; i++) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (i < 3) {
          await Future.delayed(const Duration(milliseconds: 30));
        }
      }
      
      // Системный звук успеха (если доступен на платформе)
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (e) {
        debugPrint('System sound not available: $e');
      }
      
      // Дополнительная обратная связь через нативные звуки (если доступны)
      try {
        await _channel.invokeMethod('playCorrectSound');
      } catch (e) {
        // Платформа не поддерживает метод - игнорируем
        debugPrint('Platform sound not available: $e');
      }
    } catch (e) {
      debugPrint('Sound error: $e');
      // Fallback на вибрацию
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> playIncorrectSound() async {
    try {
      // Простой однотонный краткий сигнал (низкий тон)
      // Используем легкую вибрацию для имитации низкого тона
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Системный звук ошибки (если доступен на платформе)
      try {
        // Используем вибрацию как основной сигнал для неправильного ответа
        await HapticFeedback.vibrate();
      } catch (e) {
        debugPrint('Haptic feedback not available: $e');
      }
      
      // Дополнительная обратная связь через нативные звуки (если доступны)
      try {
        await _channel.invokeMethod('playIncorrectSound');
      } catch (e) {
        // Платформа не поддерживает метод - игнорируем
        debugPrint('Platform sound not available: $e');
      }
      
      await Future.delayed(const Duration(milliseconds: 150));
    } catch (e) {
      debugPrint('Sound error: $e');
      // Fallback на вибрацию
      await HapticFeedback.lightImpact();
    }
  }
}


