import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';

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
            print('Fehler beim Parsen einer Frage: $e');
          }
        }
      } catch (e) {
        print('Fehler beim Laden von $filePath: $e');
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
      final String correctAnswerDe = json['correct_answer_de'] ?? '';
      final String correctAnswerRu = json['correct_answer_ru'] ?? '';
      
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

      // Все ответы вместе
      final List<String> allAnswersDe = [correctAnswerDe, ...wrongAnswersDe];
      final List<String> allAnswersRu = [correctAnswerRu, ...wrongAnswersRu];
      
      // Позиция правильного ответа (будет перемешано в QuizScreen)
      final correctIndex = 0;
      
      // Интересные факты
      List<String> factsDe = [];
      List<String> factsRu = [];
      
      if (json['interesting_facts'] != null && json['interesting_facts'] is List) {
        for (final fact in json['interesting_facts']) {
          if (fact is Map) {
            factsDe.add(fact['de'] ?? '');
            factsRu.add(fact['ru'] ?? '');
          }
        }
      }

      // Объяснение
      final String? explanationDe = json['explanation_de'];
      final String? explanationRu = json['explanation_ru'];

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
        period: json['period'],
        difficulty: json['difficulty'],
        type: json['type'],
        tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      );
    } catch (e) {
      print('Fehler beim Parsen: $e');
      return null;
    }
  }

  static List<QuizQuestion> filterQuestions(
    List<QuizQuestion> questions, {
    String? selectedCategory,
    String? selectedPeriod,
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
    periods.sort();
    return periods;
  }
}



