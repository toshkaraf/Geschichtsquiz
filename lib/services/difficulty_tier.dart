import '../models/quiz_question.dart';

/// Zwei Spielstufen: einfach (easy + medium) und schwer (hard).
enum QuizDifficultyTier {
  easy,
  hard,
}

extension QuizDifficultyTierLabels on QuizDifficultyTier {
  String get labelDe => this == QuizDifficultyTier.easy ? 'Einfach' : 'Schwer';

  String get labelRu => this == QuizDifficultyTier.easy ? 'Простые' : 'Сложные';

  String get subtitleDe =>
      this == QuizDifficultyTier.easy ? 'Leicht & mittel' : 'Anspruchsvoll';
}

class DifficultyTierFilter {
  DifficultyTierFilter._();

  static bool matches(String? rawDifficulty, QuizDifficultyTier tier) {
    final d = (rawDifficulty ?? '').trim().toLowerCase();
    switch (tier) {
      case QuizDifficultyTier.easy:
        return d.isEmpty || d == 'easy' || d == 'medium';
      case QuizDifficultyTier.hard:
        return d == 'hard';
    }
  }

  static List<QuizQuestion> apply(
    List<QuizQuestion> questions,
    QuizDifficultyTier tier,
  ) {
    return questions.where((q) => matches(q.difficulty, tier)).toList();
  }

  static int count(List<QuizQuestion> questions, QuizDifficultyTier tier) {
    return apply(questions, tier).length;
  }
}
