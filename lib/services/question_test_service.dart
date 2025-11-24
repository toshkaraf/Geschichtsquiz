import 'question_service.dart';

class QuestionTestResult {
  final int questionId;
  final String questionText;
  final int optionsCountDe;
  final int optionsCountRu;
  final String? issue;

  QuestionTestResult({
    required this.questionId,
    required this.questionText,
    required this.optionsCountDe,
    required this.optionsCountRu,
    this.issue,
  });

  bool get hasIssue => issue != null;
}

class QuestionTestService {
  /// Тестирует все вопросы и возвращает список проблемных вопросов
  static Future<List<QuestionTestResult>> testAllQuestions() async {
    final allQuestions = await QuestionService.loadAllQuestions();
    final List<QuestionTestResult> results = [];
    final List<QuestionTestResult> problematicQuestions = [];

    for (final question in allQuestions) {
      final optionsCountDe = question.optionsDe.length;
      final optionsCountRu = question.optionsRu.length;
      
      String? issue;
      
      // Проверяем, что есть минимум 4 варианта ответа
      if (optionsCountDe < 4) {
        issue = 'Только $optionsCountDe вариант(ов) на немецком (нужно минимум 4)';
      } else if (optionsCountRu < 4) {
        issue = 'Только $optionsCountRu вариант(ов) на русском (нужно минимум 4)';
      } else if (optionsCountDe != optionsCountRu) {
        issue = 'Несоответствие: $optionsCountDe вариантов DE vs $optionsCountRu вариантов RU';
      }
      
      // Проверяем на пустые варианты
      final emptyDe = question.optionsDe.where((opt) => opt.isEmpty).toList();
      final emptyRu = question.optionsRu.where((opt) => opt.isEmpty).toList();
      
      if (emptyDe.isNotEmpty || emptyRu.isNotEmpty) {
        final emptyInfo = 'Пустые варианты: ${emptyDe.length} DE, ${emptyRu.length} RU';
        issue = issue != null ? '$issue. $emptyInfo' : emptyInfo;
      }
      
      final result = QuestionTestResult(
        questionId: question.id,
        questionText: question.questionRu.isNotEmpty 
            ? question.questionRu 
            : question.questionDe,
        optionsCountDe: optionsCountDe,
        optionsCountRu: optionsCountRu,
        issue: issue,
      );
      
      results.add(result);
      
      if (result.hasIssue) {
        problematicQuestions.add(result);
      }
    }

    return problematicQuestions;
  }

  /// Получает статистику по всем вопросам
  static Future<Map<String, dynamic>> getStatistics() async {
    final allQuestions = await QuestionService.loadAllQuestions();
    final testResults = await testAllQuestions();
    
    final totalQuestions = allQuestions.length;
    final problematicCount = testResults.length;
    final validCount = totalQuestions - problematicCount;
    
    // Подсчет вопросов по количеству вариантов
    final Map<int, int> optionsDistribution = {};
    for (final question in allQuestions) {
      final count = question.optionsDe.length;
      optionsDistribution[count] = (optionsDistribution[count] ?? 0) + 1;
    }
    
    return {
      'totalQuestions': totalQuestions,
      'validQuestions': validCount,
      'problematicQuestions': problematicCount,
      'optionsDistribution': optionsDistribution,
    };
  }
}

