import 'package:flutter/material.dart';
import 'dart:math';
import '../models/quiz_question.dart';
import '../services/sound_service.dart';
import '../services/question_history_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> availableQuestions;
  final Function(QuizQuestion) onQuestionUsed;

  const QuizScreen({
    super.key,
    required this.availableQuestions,
    required this.onQuestionUsed,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizQuestion? _currentQuestion;
  bool _isTranslated = false;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  List<String> _shuffledOptionsDe = [];
  List<String> _shuffledOptionsRu = [];
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Откладываем загрузку вопроса до завершения первой сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRandomQuestion();
    });
  }

  Future<void> _loadRandomQuestion() async {
    // Filtere verfügbare Fragen basierend auf Historie
    final questionIds = widget.availableQuestions.map((q) => q.id).toList();
    final availableIds = await QuestionHistoryService.filterAvailableQuestions(questionIds);
    final availableQuestions = widget.availableQuestions.where((q) => availableIds.contains(q.id)).toList();

    if (availableQuestions.isEmpty) {
      // Alle Fragen wurden heute beantwortet oder sind nicht verfügbar
      _showEndDialog();
      return;
    }

    final random = Random();
    final index = random.nextInt(availableQuestions.length);
    final question = availableQuestions[index];
    
    // Antworten mischen
    final optionsDe = List<String>.from(question.optionsDe);
    final optionsRu = List<String>.from(question.optionsRu);
    
    // Paare von DE und RU Antworten zusammenhalten
    final List<MapEntry<String, String>> answerPairs = [];
    for (int i = 0; i < optionsDe.length; i++) {
      answerPairs.add(MapEntry(optionsDe[i], optionsRu[i]));
    }
    
    // Mischen
    answerPairs.shuffle(random);
    
    // Neue Listen erstellen und korrekten Index finden
    _shuffledOptionsDe = answerPairs.map((e) => e.key).toList();
    _shuffledOptionsRu = answerPairs.map((e) => e.value).toList();
    
    // Korrekten Index finden
    final correctAnswerDe = question.optionsDe[question.correctAnswerIndex];
    _correctAnswerIndex = _shuffledOptionsDe.indexOf(correctAnswerDe);
    
    // Neue Frage mit gemischten Antworten erstellen
    _currentQuestion = QuizQuestion(
      id: question.id,
      questionDe: question.questionDe,
      questionRu: question.questionRu,
      optionsDe: _shuffledOptionsDe,
      optionsRu: _shuffledOptionsRu,
      correctAnswerIndex: _correctAnswerIndex,
      factsDe: question.factsDe,
      factsRu: question.factsRu,
      explanationDe: question.explanationDe,
      explanationRu: question.explanationRu,
      category: question.category,
      period: question.period,
      difficulty: question.difficulty,
      type: question.type,
      tags: question.tags,
    );
    
    setState(() {
      _isTranslated = false;
      _hasAnswered = false;
      _selectedAnswerIndex = null;
    });
  }

  void _showEndDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz beendet'),
        content: const Text('Alle Fragen wurden beantwortet!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрыть диалог
              if (mounted) {
                Navigator.of(context).pop(); // Вернуться на стартовый экран
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_hasAnswered || _currentQuestion == null) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
    });

    final isCorrect = index == _currentQuestion!.correctAnswerIndex;

    // Speichere die Antwort in der Historie
    QuestionHistoryService.markQuestionAnswered(_currentQuestion!.id, isCorrect);

    // Воспроизводим звук
    if (isCorrect) {
      SoundService.playCorrectSound();
    } else {
      SoundService.playIncorrectSound();
    }

    // Показываем экран результата через небольшую задержку
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            question: _currentQuestion!,
            isCorrect: isCorrect,
            onContinue: () {
              Navigator.pop(context);
              _loadRandomQuestion();
            },
          ),
        ),
      );
    });
  }

  Color _getAnswerColor(int index) {
    if (!_hasAnswered || _currentQuestion == null) return Colors.grey.shade200;
    
    if (index == _currentQuestion!.correctAnswerIndex) {
      return Colors.green;
    }
    
    if (index == _selectedAnswerIndex && index != _currentQuestion!.correctAnswerIndex) {
      return Colors.red;
    }
    
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final question = _isTranslated
        ? currentQuestion.questionTranslated
        : currentQuestion.question;
    final options = _isTranslated
        ? currentQuestion.optionsTranslated
        : currentQuestion.options;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () {
              setState(() {
                _isTranslated = !_isTranslated;
              });
            },
            tooltip: 'Übersetzen',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isTranslated) ...[
                const SizedBox(height: 8),
                Text(
                  currentQuestion.question,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getAnswerColor(index),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAnswerIndex == index
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            options[index],
                            style: TextStyle(
                              fontSize: 22,
                              color: _hasAnswered && 
                                     (index == currentQuestion.correctAnswerIndex ||
                                      index == _selectedAnswerIndex)
                                  ? Colors.white
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                          if (_isTranslated) ...[
                            const SizedBox(height: 4),
                            Text(
                              currentQuestion.options[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: _hasAnswered && 
                                       (index == currentQuestion.correctAnswerIndex ||
                                        index == _selectedAnswerIndex)
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

