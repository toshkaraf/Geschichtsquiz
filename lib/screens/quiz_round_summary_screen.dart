import 'package:flutter/material.dart';

/// Abschlussbilanz einer Quizrunde — Texte deutsch (Niveau B2).
class QuizRoundSummaryScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const QuizRoundSummaryScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  String _motivationalParagraph() {
    if (totalQuestions == 0) {
      return 'In dieser Runde wurden keine Fragen gespielt. Versuchen Sie es später erneut.';
    }
    final ratio = correctAnswers / totalQuestions;
    if (ratio >= 1.0) {
      return 'Hervorragend: Sie haben jede einzelne Frage richtig beantwortet. '
          'So festigt sich Ihr Überblick besonders nachhaltig — bleiben Sie neugierig auf die nächsten Runden!';
    }
    if (ratio >= 0.8) {
      return 'Sehr starker Durchgang! Die meisten Antworten stimmten, und die wenigen '
          'Lücken können Sie beim nächsten Mal gezielt schließen. Weiter mit der gleichen Konsequenz!';
    }
    if (ratio >= 0.6) {
      return 'Solides Ergebnis: mehr als die Hälfte saß. Nutzen Sie die Erklärungen und '
          'Fakten, um die falsch gewählten Themen aktiv nachzuschärfen — Fortschritt entsteht Schritt für Schritt.';
    }
    if (ratio >= 0.4) {
      return 'Noch Luft nach oben, aber genau hier lohnt üben. Jede wiederholte Frage '
          'trainiert Ihre Merkfähigkeit — geben Sie nicht auf, Geschichte braucht manchmal einfach Geduld.';
    }
    return 'Anspruchsvolle Runde! Fehler sind keine Niederlage, sondern Hinweise, wo '
          'Sie tiefer graben sollten. Nehmen Sie sich Zeit mit den Erläuterungen — beim nächsten Mal wirkt vieles automatisch leichter.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auswertung'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.analytics_outlined,
                  size: 72,
                  color: Colors.blue.shade800,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ergebnis Ihrer Runde',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Text(
                          totalQuestions == 1
                              ? (correctAnswers == 1
                                  ? 'Sie haben die eine Frage in dieser Runde richtig beantwortet.'
                                  : 'In dieser Runde war leider keine Antwort richtig — beim nächsten Mal klappt es oft schon besser.')
                              : 'Sie haben $correctAnswers von $totalQuestions Fragen '
                                  'richtig beantwortet.',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _motivationalParagraph(),
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.45,
                        color: Colors.blueGrey.shade800,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'Zurück zur Bereichsauswahl',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
