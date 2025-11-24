import 'dart:convert';
import 'dart:io';

/// Скрипт для конвертации JSON файлов с вопросами в стандартный формат
/// 
/// Стандартный формат:
/// - question_ru / question_de
/// - correct_answer_ru / correct_answer_de
/// - wrong_answers_ru / wrong_answers_de (массивы строк)
/// - explanation_ru / explanation_de
/// - interesting_facts (массив объектов с ru/de)

void main(List<String> args) {
  if (args.isEmpty) {
    print('Использование: dart tools/convert_questions_format.dart <путь_к_файлу>');
    print('Пример: dart tools/convert_questions_format.dart lib/data/Fragen/Detailed/detailed_questions_26_40.json');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);

  if (!file.existsSync()) {
    print('Ошибка: Файл не найден: $filePath');
    exit(1);
  }

  try {
    print('Чтение файла: $filePath');
    final jsonString = file.readAsStringSync();
    final List<dynamic> jsonData = json.decode(jsonString);

    print('Найдено вопросов: ${jsonData.length}');
    print('Конвертация в стандартный формат...');

    final List<Map<String, dynamic>> convertedData = [];

    for (int i = 0; i < jsonData.length; i++) {
      final item = jsonData[i] as Map<String, dynamic>;
      final converted = _convertQuestion(item, i + 1);
      if (converted != null) {
        convertedData.add(converted);
      } else {
        print('⚠️  Пропущен вопрос #${item['id'] ?? i + 1}: не удалось конвертировать');
      }
    }

    // Создаём резервную копию
    final backupPath = '$filePath.backup';
    file.copySync(backupPath);
    print('✓ Создана резервная копия: $backupPath');

    // Сохраняем конвертированные данные
    final output = const JsonEncoder.withIndent('  ').convert(convertedData);
    file.writeAsStringSync(output);
    print('✓ Файл успешно конвертирован: $filePath');
    print('✓ Конвертировано вопросов: ${convertedData.length}');

  } catch (e) {
    print('Ошибка: $e');
    exit(1);
  }
}

Map<String, dynamic>? _convertQuestion(Map<String, dynamic> json, int defaultId) {
  try {
    final result = <String, dynamic>{};

    // ID
    result['id'] = json['id'] ?? defaultId;

    // Вопросы - конвертируем разные форматы
    if (json.containsKey('question_ru') && json.containsKey('question_de')) {
      result['question_ru'] = json['question_ru'];
      result['question_de'] = json['question_de'];
    } else if (json.containsKey('question') && json.containsKey('question_de')) {
      result['question_ru'] = json['question'];
      result['question_de'] = json['question_de'];
    } else {
      print('⚠️  Вопрос #${result['id']}: отсутствует question_ru или question_de');
      return null;
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
      print('⚠️  Вопрос #${result['id']}: отсутствует правильный ответ');
      return null;
    }

    // Неправильные ответы - конвертируем разные форматы
    if (json.containsKey('wrong_answers_ru') && json.containsKey('wrong_answers_de')) {
      // Уже в правильном формате (массивы строк)
      result['wrong_answers_ru'] = json['wrong_answers_ru'];
      result['wrong_answers_de'] = json['wrong_answers_de'];
    } else if (json.containsKey('wrong_answers') && json['wrong_answers'] is List) {
      // Конвертируем из формата с объектами
      final wrongAnswers = json['wrong_answers'] as List;
      final wrongAnswersRu = <String>[];
      final wrongAnswersDe = <String>[];

      for (final wrongAnswer in wrongAnswers) {
        if (wrongAnswer is Map) {
          wrongAnswersRu.add(wrongAnswer['ru'] ?? '');
          wrongAnswersDe.add(wrongAnswer['de'] ?? '');
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
    print('Ошибка при конвертации вопроса: $e');
    return null;
  }
}

