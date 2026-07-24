import '../models/quiz_question.dart';

class CurriculumSection {
  final String id;
  final String titleDe;
  final String subtitleDe;
  final List<QuizQuestion> questions;

  const CurriculumSection({
    required this.id,
    required this.titleDe,
    required this.subtitleDe,
    required this.questions,
  });
}

class CurriculumStructureService {
  static const List<(String, String, String)> _schoolSections = [
    (
      'prehistory',
      'Vorgeschichte und Frühgeschichte',
      'Vorgeschichte / Frühgeschichte',
    ),
    (
      'early_civilizations',
      'Frühe Hochkulturen',
      'Frühe Hochkulturen',
    ),
    (
      'antiquity',
      'Antike',
      'Griechenland, Rom und antike Welt',
    ),
    (
      'middle_ages',
      'Mittelalter',
      'Mittelalter',
    ),
    (
      'early_modern',
      'Frühe Neuzeit',
      'Frühe Neuzeit',
    ),
    (
      'modern_19th',
      'Neuzeit (19. Jahrhundert)',
      'Neuzeit / 19. Jahrhundert',
    ),
    (
      'modern_20th',
      '20. Jahrhundert',
      '20. Jahrhundert',
    ),
    (
      'contemporary',
      'Zeitgeschichte',
      'Zeitgeschichte / Gegenwart',
    ),
  ];

  static List<CurriculumSection> buildSchoolSections(
    List<QuizQuestion> allQuestions,
  ) {
    final grouped = <String, List<QuizQuestion>>{
      for (final section in _schoolSections) section.$1: <QuizQuestion>[],
    };

    for (final question in allQuestions) {
      final sectionId = _mapEpochToSchoolSection(question.period);
      grouped.putIfAbsent(sectionId, () => <QuizQuestion>[]).add(question);
    }

    return _schoolSections
        .map(
          (section) => CurriculumSection(
            id: section.$1,
            titleDe: section.$2,
            subtitleDe: section.$3,
            questions: grouped[section.$1]!..sort((a, b) => a.id.compareTo(b.id)),
          ),
        )
        .toList();
  }

  static String _mapEpochToSchoolSection(String? epoch) {
    switch (epoch) {
      case 'Urgeschichte':
        return 'prehistory';
      case 'Alte Hochkulturen':
      case 'Mittlere und späte Bronzezeit':
      case 'Frühe Eisenzeit und archaische Antike':
        return 'early_civilizations';
      case 'Klassische Antike':
      case 'Hellenismus und Römische Republik':
      case 'Römische Kaiserzeit':
      case 'Spätantike':
        return 'antiquity';
      case 'Mittelalter und Frühe Neuzeit':
        return 'middle_ages';
      case 'Frühe Neuzeit':
        return 'early_modern';
      case '19. Jahrhundert':
        return 'modern_19th';
      case '20. Jahrhundert':
        return 'modern_20th';
      case 'Neuzeit (sonstige)':
        return 'early_modern';
      default:
        return 'contemporary';
    }
  }
}
