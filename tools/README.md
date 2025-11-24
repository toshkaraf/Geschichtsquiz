# Скрипты для конвертации вопросов

## Описание

Эти скрипты конвертируют JSON файлы с вопросами в единый стандартный формат.

## Стандартный формат

Все файлы должны использовать следующий формат:

```json
{
  "id": 1,
  "question_ru": "Вопрос на русском",
  "question_de": "Frage auf Deutsch",
  "correct_answer_ru": "Правильный ответ на русском",
  "correct_answer_de": "Richtige Antwort auf Deutsch",
  "wrong_answers_ru": [
    "Неправильный ответ 1",
    "Неправильный ответ 2",
    "Неправильный ответ 3"
  ],
  "wrong_answers_de": [
    "Falsche Antwort 1",
    "Falsche Antwort 2",
    "Falsche Antwort 3"
  ],
  "explanation_ru": "Объяснение на русском",
  "explanation_de": "Erklärung auf Deutsch",
  "interesting_facts": [
    {
      "ru": "Факт на русском",
      "de": "Fakt auf Deutsch"
    }
  ],
  "difficulty": "medium",
  "category": "Категория",
  "type": "factual",
  "period": "3100 BCE",
  "tags": ["тег1", "тег2"]
}
```

## Использование

### Массовая конвертация всех файлов

```bash
dart tools/convert_all_questions.dart
```

Этот скрипт:
- Обработает все файлы из списка в `question_service.dart`
- Создаст резервные копии (`.backup`)
- Конвертирует файлы в стандартный формат
- Покажет статистику

### Конвертация одного файла

```bash
dart tools/convert_questions_format.dart lib/data/Fragen/Detailed/detailed_questions_26_40.json
```

## Поддерживаемые форматы для конвертации

Скрипты автоматически конвертируют следующие форматы:

1. **Формат с `answer` и `answer_de`**:
   ```json
   {
     "question": "Вопрос",
     "question_de": "Frage",
     "answer": "Ответ",
     "answer_de": "Antwort",
     "wrong_answers": [
       {"ru": "Неправильный", "de": "Falsch"}
     ]
   }
   ```

2. **Формат с `answer_ru` и `answer_de`**:
   ```json
   {
     "answer_ru": "Ответ",
     "answer_de": "Antwort",
     "wrong_answers_ru": ["Неправильный"],
     "wrong_answers_de": ["Falsch"]
   }
   ```

3. **Стандартный формат** (уже правильный):
   ```json
   {
     "correct_answer_ru": "Ответ",
     "correct_answer_de": "Antwort",
     "wrong_answers_ru": ["Неправильный"],
     "wrong_answers_de": ["Falsch"]
   }
   ```

## Безопасность

- Скрипты автоматически создают резервные копии (`.backup`)
- Если резервная копия уже существует, она не перезаписывается
- Оригинальные файлы сохраняются до успешной конвертации

## После конвертации

После успешной конвертации:
1. Проверьте работу приложения
2. Удалите резервные копии (`.backup`), если всё работает корректно
3. Упрощённый парсер в `question_service.dart` теперь работает только со стандартным форматом

