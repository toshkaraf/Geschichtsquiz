import 'dart:convert';
import 'dart:io';

/// Скрипт для массовой конвертации всех JSON файлов с вопросами в стандартный формат
/// 
/// Стандартный формат:
/// - question_ru / question_de
/// - correct_answer_ru / correct_answer_de
/// - wrong_answers_ru / wrong_answers_de (массивы строк)
/// - explanation_ru / explanation_de
/// - interesting_facts (массив объектов с ru/de)

void main(List<String> args) {
  // Список всех файлов для конвертации
  // Примечание: detailed_questions_01_25.json уже в правильном формате, не конвертируем
  final filesToConvert = [
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

  print('🚀 Начинаем массовую конвертацию файлов...\n');

  int totalConverted = 0;
  int totalQuestions = 0;
  int totalErrors = 0;

  for (final filePath in filesToConvert) {
    final file = File(filePath);

    if (!file.existsSync()) {
      print('⚠️  Файл не найден: $filePath');
      totalErrors++;
      continue;
    }

    try {
      print('📄 Обработка: $filePath');
      final jsonString = file.readAsStringSync();
      final List<dynamic> jsonData = json.decode(jsonString);

      print('   Найдено вопросов: ${jsonData.length}');
      print('   Конвертация...');

      final List<Map<String, dynamic>> convertedData = [];
      int questionNumber = 1;

      for (final item in jsonData) {
        final questionId = (item as Map<String, dynamic>)['id'] ?? questionNumber;
        final converted = _convertQuestion(item, questionId);
        if (converted != null) {
          convertedData.add(converted);
        } else {
          print('   ⚠️  Пропущен вопрос #$questionId');
          totalErrors++;
        }
        questionNumber++;
      }

      // Создаём резервную копию
      final backupPath = '$filePath.backup';
      if (!File(backupPath).existsSync()) {
        file.copySync(backupPath);
        print('   ✓ Создана резервная копия: $backupPath');
      } else {
        print('   ℹ️  Резервная копия уже существует, пропускаем');
      }

      // Сохраняем конвертированные данные
      final output = const JsonEncoder.withIndent('  ').convert(convertedData);
      file.writeAsStringSync(output);
      
      print('   ✓ Успешно конвертировано: ${convertedData.length} вопросов\n');
      
      totalConverted++;
      totalQuestions += convertedData.length;

    } catch (e, stackTrace) {
      print('   ❌ Ошибка при обработке $filePath: $e');
      print('   Stack trace: $stackTrace\n');
      totalErrors++;
    }
  }

  print('${'=' * 60}');
  print('📊 Итоги конвертации:');
  print('   ✓ Файлов обработано: $totalConverted');
  print('   ✓ Всего вопросов конвертировано: $totalQuestions');
  if (totalErrors > 0) {
    print('   ⚠️  Ошибок/пропущено: $totalErrors');
  }
  print('${'=' * 60}');
}

Map<String, dynamic>? _convertQuestion(Map<String, dynamic> json, dynamic questionId) {
  try {
    final result = <String, dynamic>{};

    // ID
    result['id'] = questionId;

    // Вопросы - конвертируем разные форматы
    if (json.containsKey('question_ru') && json.containsKey('question_de')) {
      result['question_ru'] = json['question_ru'];
      result['question_de'] = json['question_de'];
    } else if (json.containsKey('question') && json.containsKey('question_de')) {
      result['question_ru'] = json['question'];
      result['question_de'] = json['question_de'];
    } else {
      return null; // Пропускаем, если нет вопросов
    }

    // Правильный ответ - конвертируем разные форматы
    if (json.containsKey('correct_answer_ru') && json.containsKey('correct_answer_de')) {
      result['correct_answer_ru'] = json['correct_answer_ru'];
      result['correct_answer_de'] = json['correct_answer_de'];
    } else if (json.containsKey('answer_ru') && json.containsKey('answer_de')) {
      result['correct_answer_ru'] = json['answer_ru'];
      result['correct_answer_de'] = json['answer_de'];
    } else if (json.containsKey('answer') && json.containsKey('answer_de')) {
      result['correct_answer_ru'] = json['answer'];
      result['correct_answer_de'] = json['answer_de'];
    } else {
      return null; // Пропускаем, если нет правильного ответа
    }

    // Неправильные ответы - конвертируем разные форматы
    if (json.containsKey('wrong_answers_ru') && json.containsKey('wrong_answers_de')) {
      // Уже в правильном формате (массивы строк)
      final wrongAnswersRu = json['wrong_answers_ru'];
      final wrongAnswersDe = json['wrong_answers_de'];
      
      if (wrongAnswersRu is List && wrongAnswersDe is List) {
        result['wrong_answers_ru'] = wrongAnswersRu;
        result['wrong_answers_de'] = wrongAnswersDe;
      } else {
        result['wrong_answers_ru'] = [];
        result['wrong_answers_de'] = [];
      }
    } else if (json.containsKey('wrong_answers') && json['wrong_answers'] is List) {
      // Конвертируем из формата с объектами
      final wrongAnswers = json['wrong_answers'] as List;
      final wrongAnswersRu = <String>[];
      final wrongAnswersDe = <String>[];

      for (final wrongAnswer in wrongAnswers) {
        if (wrongAnswer is Map) {
          final ru = wrongAnswer['ru'];
          final de = wrongAnswer['de'];
          if (ru != null && ru.toString().isNotEmpty) {
            wrongAnswersRu.add(ru.toString());
          }
          if (de != null && de.toString().isNotEmpty) {
            wrongAnswersDe.add(de.toString());
          }
        }
      }

      result['wrong_answers_ru'] = wrongAnswersRu;
      result['wrong_answers_de'] = wrongAnswersDe;
    } else {
      // Нет неправильных ответов
      result['wrong_answers_ru'] = [];
      result['wrong_answers_de'] = [];
    }

    // Объяснение
    if (json.containsKey('explanation_ru') && json.containsKey('explanation_de')) {
      result['explanation_ru'] = json['explanation_ru'];
      result['explanation_de'] = json['explanation_de'];
    } else if (json.containsKey('explanation')) {
      if (json['explanation'] is Map) {
        result['explanation_ru'] = json['explanation']['ru'];
        result['explanation_de'] = json['explanation']['de'];
      } else if (json['explanation'] is String) {
        result['explanation_ru'] = json['explanation'];
        result['explanation_de'] = ''; // Нет немецкого перевода
      }
    }

    // Интересные факты (уже в правильном формате)
    if (json.containsKey('interesting_facts')) {
      result['interesting_facts'] = json['interesting_facts'];
    }

    // Остальные поля
    if (json.containsKey('difficulty')) result['difficulty'] = json['difficulty'];
    if (json.containsKey('category')) result['category'] = json['category'];
    if (json.containsKey('type')) result['type'] = json['type'];
    if (json.containsKey('period')) result['period'] = json['period'];
    if (json.containsKey('tags')) result['tags'] = json['tags'];

    return result;
  } catch (e) {
    return null;
  }
}

