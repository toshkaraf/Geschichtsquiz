import 'package:flutter/material.dart';
import '../services/difficulty_tier.dart';

/// Segmented control: Einfach / Schwer.
class DifficultyTierToggle extends StatelessWidget {
  final QuizDifficultyTier selected;
  final ValueChanged<QuizDifficultyTier> onChanged;
  final int? easyCount;
  final int? hardCount;

  const DifficultyTierToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.easyCount,
    this.hardCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final easyLabel = easyCount != null
        ? '${QuizDifficultyTier.easy.labelDe} ($easyCount)'
        : QuizDifficultyTier.easy.labelDe;
    final hardLabel = hardCount != null
        ? '${QuizDifficultyTier.hard.labelDe} ($hardCount)'
        : QuizDifficultyTier.hard.labelDe;

    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schwierigkeit',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<QuizDifficultyTier>(
              segments: [
                ButtonSegment(
                  value: QuizDifficultyTier.easy,
                  label: Text(easyLabel),
                  icon: const Icon(Icons.sentiment_satisfied_alt),
                ),
                ButtonSegment(
                  value: QuizDifficultyTier.hard,
                  label: Text(hardLabel),
                  icon: const Icon(Icons.psychology_alt),
                ),
              ],
              selected: {selected},
              onSelectionChanged: (Set<QuizDifficultyTier> next) {
                if (next.isNotEmpty) onChanged(next.first);
              },
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selected.subtitleDe,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Variant for screens with a light AppBar background.
class DifficultyTierToggleBar extends StatelessWidget {
  final QuizDifficultyTier selected;
  final ValueChanged<QuizDifficultyTier> onChanged;
  final int? easyCount;
  final int? hardCount;

  const DifficultyTierToggleBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.easyCount,
    this.hardCount,
  });

  @override
  Widget build(BuildContext context) {
    final easyLabel = easyCount != null
        ? '${QuizDifficultyTier.easy.labelDe} ($easyCount)'
        : QuizDifficultyTier.easy.labelDe;
    final hardLabel = hardCount != null
        ? '${QuizDifficultyTier.hard.labelDe} ($hardCount)'
        : QuizDifficultyTier.hard.labelDe;

    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Schwierigkeit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<QuizDifficultyTier>(
            segments: [
              ButtonSegment(
                value: QuizDifficultyTier.easy,
                label: Text(easyLabel),
              ),
              ButtonSegment(
                value: QuizDifficultyTier.hard,
                label: Text(hardLabel),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (Set<QuizDifficultyTier> next) {
              if (next.isNotEmpty) onChanged(next.first);
            },
          ),
        ],
      ),
    );
  }
}
