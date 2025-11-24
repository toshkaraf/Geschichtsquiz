import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionHistoryService {
  static const String _answeredTodayKey = 'answered_questions_today';
  static const String _wrongAnswersKey = 'wrong_answers';
  static const String _lastDateKey = 'last_date';
  static const int _retryDelayMinutes = 20;

  /// Prüft, ob eine Frage heute angezeigt werden darf
  static Future<bool> canShowQuestion(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Prüfe, ob sich das Datum geändert hat
    await _checkDateChange(prefs);
    
    // Hole die Liste der heute beantworteten Fragen
    final answeredTodayJson = prefs.getString(_answeredTodayKey);
    if (answeredTodayJson != null) {
      final answeredToday = List<int>.from(jsonDecode(answeredTodayJson));
      if (answeredToday.contains(questionId)) {
        // Frage wurde heute bereits beantwortet - prüfe, ob sie falsch war
        return await _canRetryWrongAnswer(prefs, questionId);
      }
    }
    
    // Frage wurde heute noch nicht beantwortet
    return true;
  }

  /// Prüft, ob eine falsch beantwortete Frage wieder angezeigt werden darf (nach 20 Minuten)
  static Future<bool> _canRetryWrongAnswer(SharedPreferences prefs, int questionId) async {
    final wrongAnswersJson = prefs.getString(_wrongAnswersKey);
    if (wrongAnswersJson == null) {
      return false;
    }
    
    final wrongAnswers = Map<String, dynamic>.from(jsonDecode(wrongAnswersJson));
    final questionIdStr = questionId.toString();
    
    if (!wrongAnswers.containsKey(questionIdStr)) {
      // Frage wurde korrekt beantwortet, nicht erneut anzeigen
      return false;
    }
    
    // Frage wurde falsch beantwortet - prüfe Zeitstempel
    final timestamp = wrongAnswers[questionIdStr] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMinutes = (now - timestamp) / (1000 * 60);
    
    return elapsedMinutes >= _retryDelayMinutes;
  }

  /// Markiert eine Frage als beantwortet
  static Future<void> markQuestionAnswered(int questionId, bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Prüfe, ob sich das Datum geändert hat
    await _checkDateChange(prefs);
    
    // Füge zur Liste der heute beantworteten Fragen hinzu
    final answeredTodayJson = prefs.getString(_answeredTodayKey);
    List<int> answeredToday = [];
    if (answeredTodayJson != null) {
      answeredToday = List<int>.from(jsonDecode(answeredTodayJson));
    }
    
    if (!answeredToday.contains(questionId)) {
      answeredToday.add(questionId);
      await prefs.setString(_answeredTodayKey, jsonEncode(answeredToday));
    }
    
    // Wenn falsch beantwortet, speichere Zeitstempel
    if (!isCorrect) {
      final wrongAnswersJson = prefs.getString(_wrongAnswersKey);
      Map<String, dynamic> wrongAnswers = {};
      if (wrongAnswersJson != null) {
        wrongAnswers = Map<String, dynamic>.from(jsonDecode(wrongAnswersJson));
      }
      wrongAnswers[questionId.toString()] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_wrongAnswersKey, jsonEncode(wrongAnswers));
    } else {
      // Wenn korrekt beantwortet, entferne aus falschen Antworten (falls vorhanden)
      final wrongAnswersJson = prefs.getString(_wrongAnswersKey);
      if (wrongAnswersJson != null) {
        final wrongAnswers = Map<String, dynamic>.from(jsonDecode(wrongAnswersJson));
        wrongAnswers.remove(questionId.toString());
        await prefs.setString(_wrongAnswersKey, jsonEncode(wrongAnswers));
      }
    }
  }

  /// Prüft, ob sich das Datum geändert hat und setzt die Historie zurück
  static Future<void> _checkDateChange(SharedPreferences prefs) async {
    final lastDateStr = prefs.getString(_lastDateKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    if (lastDateStr != todayStr) {
      // Neuer Tag - setze Historie zurück
      await prefs.remove(_answeredTodayKey);
      await prefs.remove(_wrongAnswersKey);
      await prefs.setString(_lastDateKey, todayStr);
    }
  }

  /// Filtert Fragen, die angezeigt werden dürfen
  static Future<List<int>> filterAvailableQuestions(List<int> questionIds) async {
    final availableQuestions = <int>[];
    
    for (final questionId in questionIds) {
      if (await canShowQuestion(questionId)) {
        availableQuestions.add(questionId);
      }
    }
    
    return availableQuestions;
  }

  /// Gibt die Anzahl der verfügbaren Fragen zurück
  static Future<int> getAvailableQuestionCount(List<int> allQuestionIds) async {
    final available = await filterAvailableQuestions(allQuestionIds);
    return available.length;
  }
}

