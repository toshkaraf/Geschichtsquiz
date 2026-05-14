import 'package:flutter/material.dart';
import 'dart:math';
import '../models/quiz_question.dart';
import '../services/sound_service.dart';
import '../services/question_history_service.dart';
import 'quiz_round_summary_screen.dart';
import '../widgets/facts_dialog.dart';

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
  static const int _questionsPerRound = 10;

  List<QuizQuestion> _roundQueue = [];
  int _questionIndexInRound = 0;
  int _correctInRound = 0;

  QuizQuestion? _currentQuestion;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  List<String> _shuffledOptionsDe = [];
  List<String> _shuffledOptionsRu = [];
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRound();
    });
  }

  Future<void> _startRound() async {
    final questionIds = widget.availableQuestions.map((q) => q.id).toList();
    final availableIds = await QuestionHistoryService.filterAvailableQuestions(
      questionIds,
    );
    final pool =
        widget.availableQuestions
            .where((q) => availableIds.contains(q.id))
            .toList();

    if (pool.isEmpty) {
      _showEndDialog();
      return;
    }

    pool.shuffle(Random());
    final n = min(_questionsPerRound, pool.length);
    setState(() {
      _roundQueue = pool.take(n).toList();
      _questionIndexInRound = 0;
      _correctInRound = 0;
    });

    _applyQuestionPayload(_roundQueue.first);
  }

  void _applyQuestionPayload(QuizQuestion question) {
    final random = Random();
    final optionsDe = List<String>.from(question.optionsDe);
    final optionsRu = List<String>.from(question.optionsRu);

    final List<MapEntry<String, String>> answerPairs = [];
    for (int i = 0; i < optionsDe.length; i++) {
      answerPairs.add(MapEntry(optionsDe[i], optionsRu[i]));
    }

    for (int i = answerPairs.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = answerPairs[i];
      answerPairs[i] = answerPairs[j];
      answerPairs[j] = temp;
    }

    _shuffledOptionsDe = answerPairs.map((e) => e.key).toList();
    _shuffledOptionsRu = answerPairs.map((e) => e.value).toList();

    final correctAnswerDe = question.optionsDe[question.correctAnswerIndex];
    _correctAnswerIndex = _shuffledOptionsDe.indexOf(correctAnswerDe);

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
      _hasAnswered = false;
      _selectedAnswerIndex = null;
    });

    SoundService.playNewQuestionSound();
  }

  void _showEndDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz beendet'),
            content: const Text(
              'Für diese Auswahl gibt es keine freien Fragen mehr: nach richtiger Antwort mindestens einen Monat Sperre, nach falscher eine Woche.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _goToNextAfterResult() {
    if (!mounted) return;
    _questionIndexInRound++;
    if (_questionIndexInRound >= _roundQueue.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder:
              (context) => QuizRoundSummaryScreen(
                correctAnswers: _correctInRound,
                totalQuestions: _roundQueue.length,
              ),
        ),
      );
      return;
    }
    _applyQuestionPayload(_roundQueue[_questionIndexInRound]);
  }

  Future<void> _selectAnswer(int index) async {
    if (_hasAnswered || _currentQuestion == null) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
    });

    final isCorrect = index == _currentQuestion!.correctAnswerIndex;

    // Warten, bis die Sperre in SharedPreferences steht — sonst kann die nächste Runde die Frage noch ziehen.
    await QuestionHistoryService.markQuestionAnswered(
      _currentQuestion!.id,
      isCorrect,
    );

    if (isCorrect) {
      _correctInRound++;
      SoundService.playCorrectSound();
    } else {
      SoundService.playIncorrectSound();
    }

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    await _showFactsAndContinue(_currentQuestion!);
  }

  Future<void> _showFactsAndContinue(QuizQuestion question) async {
    final facts =
        question.facts
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    if (!mounted) return;
    if (facts.isEmpty) {
      _goToNextAfterResult();
      return;
    }

    final idx = await QuestionHistoryService.takeNextFactDisplayIndex(
      question.id,
      facts.length,
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FactsDialog(fact: facts[idx]),
    );

    if (mounted) {
      _goToNextAfterResult();
    }
  }

  Color _getAnswerColor(int index) {
    if (!_hasAnswered || _currentQuestion == null) return Colors.grey.shade200;

    if (index == _currentQuestion!.correctAnswerIndex) {
      return Colors.green;
    }

    if (index == _selectedAnswerIndex &&
        index != _currentQuestion!.correctAnswerIndex) {
      return Colors.red;
    }

    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = currentQuestion.question;
    final options = currentQuestion.options;
    final progressTitle =
        _roundQueue.isEmpty
            ? 'Geschichtsquiz'
            : 'Frage ${_questionIndexInRound + 1} von ${_roundQueue.length}';

    return Scaffold(
      appBar: AppBar(title: Text(progressTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Richtig beantwortete Fragen bleiben mindestens einen Kalendermonat aus dem Fragenpool; nach einer falschen Antwort 7 Tage.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                          color:
                              _selectedAnswerIndex == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 12, top: 2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _hasAnswered &&
                                          (index ==
                                                  currentQuestion
                                                      .correctAnswerIndex ||
                                              index == _selectedAnswerIndex)
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.blue.withValues(alpha: 0.12),
                              border: Border.all(
                                color:
                                    _hasAnswered &&
                                            (index ==
                                                    currentQuestion
                                                        .correctAnswerIndex ||
                                                index == _selectedAnswerIndex)
                                        ? Colors.white
                                        : Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    color:
                                        _hasAnswered &&
                                                (index ==
                                                        currentQuestion
                                                            .correctAnswerIndex ||
                                                    index == _selectedAnswerIndex)
                                            ? Colors.white
                                            : Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 22,
                                    color:
                                        _hasAnswered &&
                                                (index ==
                                                        currentQuestion
                                                            .correctAnswerIndex ||
                                                    index ==
                                                        _selectedAnswerIndex)
                                            ? Colors.white
                                            : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
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
