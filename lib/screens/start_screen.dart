import 'dart:math';

import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/curriculum_structure_service.dart';
import '../services/difficulty_tier.dart';
import '../services/question_history_service.dart';
import '../services/question_service.dart';
import '../widgets/difficulty_tier_toggle.dart';
import 'quiz_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<QuizQuestion> _allQuestions = [];
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startQuizForSelection(List<QuizQuestion> selectedQuestions) async {
    if (selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Für diesen Bereich sind keine Fragen vorhanden.'),
        ),
      );
      return;
    }

    final questionIds = selectedQuestions.map((q) => q.id).toList();
    final availableIds = await QuestionHistoryService.filterAvailableQuestions(questionIds);
    if (!mounted) return;
    final availableQuestions =
        selectedQuestions.where((q) => availableIds.contains(q.id)).toList();

    if (availableQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alle Fragen in diesem Bereich sind gesperrt: nach richtiger Antwort mindestens einen Monat, nach falscher 7 Tage.',
          ),
        ),
      );
      return;
    }

    final randomized = List<QuizQuestion>.from(availableQuestions)..shuffle(Random());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuizScreenWrapper(
          questions: randomized,
        ),
      ),
    );
  }

  void _openSectionSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionSelectionScreen(
          allQuestions: _allQuestions,
          onStartQuiz: _startQuizForSelection,
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
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.quiz,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Geschichtsquiz',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton.icon(
                        onPressed:
                            _allQuestions.isNotEmpty ? _openSectionSelection : null,
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
                        icon: const Icon(Icons.history_edu),
                        label: const Text(
                          'Bereich wählen',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_allQuestions.length} Fragen',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
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

class SectionSelectionScreen extends StatefulWidget {
  final List<QuizQuestion> allQuestions;
  final Future<void> Function(List<QuizQuestion>) onStartQuiz;

  const SectionSelectionScreen({
    super.key,
    required this.allQuestions,
    required this.onStartQuiz,
  });

  @override
  State<SectionSelectionScreen> createState() => _SectionSelectionScreenState();
}

class _SectionSelectionScreenState extends State<SectionSelectionScreen> {
  QuizDifficultyTier _tier = QuizDifficultyTier.easy;

  List<QuizQuestion> get _tierQuestions =>
      DifficultyTierFilter.apply(widget.allQuestions, _tier);

  void _setTier(QuizDifficultyTier tier) {
    setState(() => _tier = tier);
  }

  @override
  Widget build(BuildContext context) {
    final tierQuestions = _tierQuestions;
    final sections = CurriculumStructureService.buildSchoolSections(tierQuestions);
    final easyCount =
        DifficultyTierFilter.count(widget.allQuestions, QuizDifficultyTier.easy);
    final hardCount =
        DifficultyTierFilter.count(widget.allQuestions, QuizDifficultyTier.hard);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bereich auswählen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DifficultyTierToggleBar(
            selected: _tier,
            easyCount: easyCount,
            hardCount: hardCount,
            onChanged: _setTier,
          ),
          Expanded(
            child: tierQuestions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Keine ${_tier.labelDe.toLowerCase()}en Fragen in der Datenbank.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final count = section.questions.length;
                      final enabled = count > 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          enabled: enabled,
                          leading: CircleAvatar(
                            backgroundColor: enabled
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            section.titleDe,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${section.subtitleDe}\n'
                            '${_tier.labelDe}: $count Fragen',
                          ),
                          isThreeLine: true,
                          trailing: Icon(
                            enabled ? Icons.play_circle_fill : Icons.block,
                            color: enabled ? null : Colors.grey,
                          ),
                          onTap: enabled
                              ? () async {
                                  await widget.onStartQuiz(section.questions);
                                }
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
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
