import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../widgets/facts_dialog.dart';
import '../widgets/explanation_dialog.dart';

class ResultScreen extends StatelessWidget {
  final QuizQuestion question;
  final bool isCorrect;
  final VoidCallback onContinue;

  const ResultScreen({
    super.key,
    required this.question,
    required this.isCorrect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCorrect ? 'Richtig!' : 'Falsch!'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 120,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 32),
            Text(
              isCorrect ? 'Richtig!' : 'Falsch!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Weiter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.lightbulb,
                      size: 48,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FactsDialog(
                          facts: question.facts,
                          factsTranslated: question.factsTranslated,
                        ),
                      );
                    },
                    tooltip: 'Interessante Fakten',
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(
                      Icons.menu_book,
                      size: 48,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      if (question.explanation != null && question.explanationTranslated != null) {
                        showDialog(
                          context: context,
                          builder: (context) => ExplanationDialog(
                            explanation: question.explanation!,
                            explanationTranslated: question.explanationTranslated!,
                          ),
                        );
                      }
                    },
                    tooltip: 'Erklärung',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

