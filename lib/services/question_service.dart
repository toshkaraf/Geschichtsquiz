import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';
import 'period_epoch_mapper.dart';

class QuestionService {
  static Future<List<QuizQuestion>> loadAllQuestions() async {
    final List<QuizQuestion> allQuestions = [];
    
    // Liste aller JSON-Dateien im Detailed-Ordner
    final jsonFiles = [
      'lib/data/Fragen/Detailed/detailed_questions_01_25.json',
      'lib/data/Fragen/Detailed/detailed_questions_26_40.json',
      'lib/data/Fragen/Detailed/detailed_41_55.json',
      'lib/data/Fragen/Detailed/detailed_questions_56_70_final.json',
      'lib/data/Fragen/Detailed/detailed_questions_71_85_final.json',
      'lib/data/Fragen/Detailed/detailed_questions_86_100_final.json',
      'lib/data/Fragen/Detailed/detailed_questions_101_115_complete.json',
      'lib/data/Fragen/Detailed/detailed_201_215_complete.json',
      'lib/data/Fragen/Detailed/detailed_201_230_complete.json',
      'lib/data/Fragen/Detailed/detailed_231_250_complete.json',
      'lib/data/Fragen/Detailed/detailed_251_300_complete.json',
      'lib/data/Fragen/Detailed/detailed_301_350_complete.json',
      'lib/data/Fragen/Detailed/detailed_351_400_complete.json',
      'lib/data/Fragen/Detailed/detailed_401_450_complete.json',
      'lib/data/Fragen/Detailed/detailed_451_500_complete.json',
      'lib/data/Fragen/Detailed/detailed_501_550_greece_b2.json',
      'lib/data/Fragen/Detailed/medieval_6001_6100.json',
      'lib/data/Fragen/Detailed/medieval_6101_6200.json',
      'lib/data/Fragen/Detailed/medieval_6201_6300.json',
      'lib/data/Fragen/Detailed/medieval_6301_6400.json',
      'lib/data/Fragen/Detailed/medieval_6401_6500.json',
      'lib/data/Fragen/Detailed/medieval_6501_6600.json',
      'lib/data/Fragen/Detailed/medieval_6601_6700.json',
      'lib/data/Fragen/Detailed/medieval_6701_6800.json',
      'lib/data/Fragen/Detailed/medieval_6801_6900.json',
      'lib/data/Fragen/Detailed/medieval_6901_7000.json',
      'lib/data/Fragen/Detailed/early_modern_7001_7047.json',
      'lib/data/Fragen/Detailed/early_modern_7048_7147.json',
      'lib/data/Fragen/Detailed/early_modern_7148_7247.json',
      'lib/data/Fragen/Detailed/early_modern_7248_7347.json',
      'lib/data/Fragen/Detailed/neuzeit19_all.json',
      'lib/data/Fragen/Detailed/zwanzigstes_all.json',
    ];

    for (final filePath in jsonFiles) {
      try {
        final String jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonData = json.decode(jsonString);
        
        for (final item in jsonData) {
          try {
            final question = _parseQuestion(item);
            if (question != null) {
              allQuestions.add(question);
            }
          } catch (e) {
            // Überspringe fehlerhafte Fragen
            debugPrint('Fehler beim Parsen einer Frage: $e');
          }
        }
      } catch (e) {
        debugPrint('Fehler beim Laden von $filePath: $e');
      }
    }

    return allQuestions;
  }

  static QuizQuestion? _parseQuestion(Map<String, dynamic> json) {
    try {
      // Стандартный формат: question_ru/question_de, correct_answer_ru/correct_answer_de, wrong_answers_ru/wrong_answers_de
      final int id = json['id'] ?? 0;
      
      // Frage-Text
      final String questionDe = json['question_de'] ?? '';
      final String questionRu = json['question_ru'] ?? '';
      
      if (questionDe.isEmpty || questionRu.isEmpty) {
        return null;
      }

      // Правильный ответ
      final String correctAnswerDe = _toConciseText(
        json['correct_answer_de'] ?? '',
        maxSentences: 1,
      );
      final String correctAnswerRu = _toConciseText(
        json['correct_answer_ru'] ?? '',
        maxSentences: 1,
      );
      
      if (correctAnswerDe.isEmpty || correctAnswerRu.isEmpty) {
        return null;
      }

      // Неправильные ответы (массивы строк)
      final List<String> wrongAnswersDe = json['wrong_answers_de'] != null 
          ? List<String>.from(json['wrong_answers_de']) 
          : [];
      final List<String> wrongAnswersRu = json['wrong_answers_ru'] != null 
          ? List<String>.from(json['wrong_answers_ru']) 
          : [];
      final conciseWrongAnswersDe = wrongAnswersDe
          .map((answer) => _toConciseText(answer, maxSentences: 1))
          .toList();
      final conciseWrongAnswersRu = wrongAnswersRu
          .map((answer) => _toConciseText(answer, maxSentences: 1))
          .toList();

      // Все ответы вместе
      final List<String> allAnswersDe = [correctAnswerDe, ...conciseWrongAnswersDe];
      final List<String> allAnswersRu = [correctAnswerRu, ...conciseWrongAnswersRu];
      
      // Позиция правильного ответа (будет перемешано в QuizScreen)
      final correctIndex = 0;
      
      // Интересные факты
      List<String> factsDe = [];
      List<String> factsRu = [];
      
      if (json['interesting_facts'] != null && json['interesting_facts'] is List) {
        for (final fact in json['interesting_facts']) {
          if (fact is Map) {
            factsDe.add(_normalizeText(fact['de'] ?? ''));
            factsRu.add(_normalizeText(fact['ru'] ?? ''));
          }
        }
      }

      // Объяснение
      final String? explanationDe = json['explanation_de'] != null
          ? _normalizeText(json['explanation_de'])
          : null;
      final String? explanationRu = json['explanation_ru'] != null
          ? _normalizeText(json['explanation_ru'])
          : null;

      return QuizQuestion(
        id: id,
        questionDe: questionDe,
        questionRu: questionRu,
        optionsDe: allAnswersDe,
        optionsRu: allAnswersRu,
        correctAnswerIndex: correctIndex,
        factsDe: factsDe,
        factsRu: factsRu,
        explanationDe: explanationDe,
        explanationRu: explanationRu,
        category: json['category'],
        period: PeriodEpochMapper.mapRawPeriodToGermanEpoch(
          json['period'] as String?,
        ),
        difficulty: json['difficulty'],
        type: json['type'],
        tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      );
    } catch (e) {
      debugPrint('Fehler beim Parsen: $e');
      return null;
    }
  }

  static List<QuizQuestion> filterQuestions(
    List<QuizQuestion> questions, {
    String? selectedCategory,
    String? selectedPeriod,
    String? selectedDifficulty,
  }) {
    return questions.where((question) {
      // Filter nach Kategorie (Land)
      if (selectedCategory != null && 
          selectedCategory.isNotEmpty &&
          question.category != selectedCategory) {
        return false;
      }

      // Filter nach Epoche (Period)
      if (selectedPeriod != null && 
          selectedPeriod.isNotEmpty &&
          question.period != selectedPeriod) {
        return false;
      }

      // Filter nach Schwierigkeitsgrad (Difficulty)
      if (selectedDifficulty != null && 
          selectedDifficulty.isNotEmpty &&
          question.difficulty != selectedDifficulty) {
        return false;
      }

      return true;
    }).toList();
  }

  static List<String> getUniqueCategories(List<QuizQuestion> questions) {
    final categories = questions
        .where((q) => q.category != null && q.category!.isNotEmpty)
        .map((q) => q.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  static List<String> getUniquePeriods(List<QuizQuestion> questions) {
    final periods = questions
        .where((q) => q.period != null && q.period!.isNotEmpty)
        .map((q) => q.period!)
        .toSet()
        .toList();
    periods.sort(PeriodEpochMapper.compareEpochLabels);
    return periods;
  }

  static List<String> getUniqueDifficulties(List<QuizQuestion> questions) {
    final difficulties = questions
        .where((q) => q.difficulty != null && q.difficulty!.isNotEmpty)
        .map((q) => q.difficulty!)
        .toSet()
        .toList();
    difficulties.sort();
    return difficulties;
  }

  /// Voller Text für Fakten/Erklärungen (nur Leerzeichen normalisieren).
  static String _normalizeText(dynamic value) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty) return '';
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Kurzfassung für Antwortoptionen in der Auswahl.
  static String _toConciseText(
    dynamic value, {
    int maxSentences = 2,
    int maxChars = 220,
  }) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty) return '';

    // Keep short labels/names untouched.
    if (!text.contains(RegExp(r'[.!?]')) && text.length <= 80) {
      return text;
    }

    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final sentencePattern = RegExp(r'[^.!?]+[.!?]?');
    final matches = sentencePattern
        .allMatches(normalized)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (matches.isEmpty) {
      return normalized.length <= maxChars
          ? normalized
          : '${normalized.substring(0, maxChars - 1).trim()}…';
    }

    final concise = matches.take(max(1, maxSentences)).join(' ');
    if (concise.length <= maxChars) return concise;
    return '${concise.substring(0, maxChars - 1).trim()}…';
  }
}



