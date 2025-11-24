import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/question_service.dart';
import '../services/question_history_service.dart';
import 'settings_screen.dart';
import 'quiz_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _filteredQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.loadAllQuestions();
      setState(() {
        _allQuestions = questions;
        _filteredQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFiltersChanged(List<QuizQuestion> filteredQuestions) {
    setState(() {
      _filteredQuestions = filteredQuestions;
    });
  }

  Future<void> _startQuiz() async {
    if (_filteredQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wählen Sie Filter aus, um Fragen anzuzeigen.'),
        ),
      );
      return;
    }

    // Filtere Fragen basierend auf Historie
    final questionIds = _filteredQuestions.map((q) => q.id).toList();
    final availableIds = await QuestionHistoryService.filterAvailableQuestions(questionIds);
    final availableQuestions = _filteredQuestions.where((q) => availableIds.contains(q.id)).toList();

    if (availableQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine Fragen verfügbar. Bitte versuchen Sie es später erneut.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuizScreenWrapper(
          questions: availableQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.quiz,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Geschichtsquiz',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 64),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              allQuestions: _allQuestions,
                              onFiltersChanged: _onFiltersChanged,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Einstellungen',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Quiz starten',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_filteredQuestions.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        '${_filteredQuestions.length} Fragen verfügbar',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _QuizScreenWrapper extends StatefulWidget {
  final List<QuizQuestion> questions;

  const _QuizScreenWrapper({required this.questions});

  @override
  State<_QuizScreenWrapper> createState() => _QuizScreenWrapperState();
}

class _QuizScreenWrapperState extends State<_QuizScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return QuizScreen(
      availableQuestions: widget.questions,
      onQuestionUsed: (_) {
        // Fragen werden nicht mehr aus der Liste entfernt,
        // sondern basierend auf der Historie gefiltert
      },
    );
  }
}


