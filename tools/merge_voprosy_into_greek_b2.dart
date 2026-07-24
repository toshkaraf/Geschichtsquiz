// dart run tools/merge_voprosy_into_greek_b2.dart
//
// Reads tools/voprosy_parsed_ru.json + tools/voprosy_de_translations.json,
// merges new questions into lib/data/Fragen/Detailed/detailed_501_550_greece_b2.json
// skipping items whose German question text duplicates an existing row.

import 'dart:convert';
import 'dart:io';

final _targetJson =
    'lib/data/Fragen/Detailed/detailed_501_550_greece_b2.json';
final _ruJson = 'tools/voprosy_parsed_ru.json';
final _deJson = 'tools/voprosy_de_translations.json';

/// Russian question norms that repeat content already stored from earlier CSV imports.
const _skipRusNormAlreadyInJson = <String>{
  'в каком городе был центр культа мистерий деметры и персефоны?',
  'в каком городе находились знаменитые «философские», или «перипатетические» колоннады?',
  'в каком городе был построен храм артемиды, включённый в список «семи чудес» мира?',
  'в каком городе был центр культа мистерий деметры и персефоны, где обещали участие в загробном блаженстве?',
  'в каком городе был построен знаменитый храм парфенон, посвящённый богине афине?',
  'в каком городе была основана академическая школа платона?',
  'в каком городе была основана перипатетическая школа аристотеля?',
  'в каком городе была основана ионийская философская школа?',
  'в каком городе был центр культа морского бога посейдона?',
  'в каком городе был центр культа мудрости и стратегии — богини афины?',
  'в каком городе был построен храм богини артемиды, включённый в список «семи чудес» мира?',
  'в каком году традиционно считают завершением греко‑персидских войн?',
};

String normQ(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

/// Best-effort period string for mapper (digits + BCE/CE).
String guessPeriodRu(Map<String, dynamic> ru) {
  final blob =
      '${ru['question']} ${ru['facts']?.join(' ') ?? ''} ${ru['explanation'] ?? ''} ${ru.values.map((x) => x?.toString() ?? '').join()}';
  final yr = RegExp(r'(\d{3,4})\s*г?\.\s*до\s*н\.э\.').firstMatch(blob);
  if (yr != null) return '${yr.group(1)} BCE';
  final yrAd = RegExp(r'(\d{3})\s*г?\.\s*н\.э\.').firstMatch(blob);
  if (yrAd != null) return '${yrAd.group(1)} CE';
  final century =
      RegExp(r'(V?[IVXLCDM]+\s*(?:-|–)?\s*V?[IVXLCDM]*\s*(?:вв?\.?)|\d+)\s*\.\s*до\s*н\.э\.',
              caseSensitive: false)
          .firstMatch(blob);
  if (century != null) return '480 BCE';
  return '5th century BCE';
}

Map<String, Object?> buildQuizEntry({
  required int id,
  required Map<String, dynamic> ru,
  required Map<String, dynamic> tr,
}) {
  final corrLetter = ru['correct_letter'] as String;
  final deOpts = Map<String, String>.from(tr['option_de'] as Map<String, dynamic>)
      .map((k, v) => MapEntry(k.toString(), v.toString()));
  final correctDe = deOpts[corrLetter]!;
  final wrongLetters = ['а', 'б', 'в', 'г'].where((x) => x != corrLetter).toList();

  final period = tr['period'] as String? ?? guessPeriodRu(ru);
  final type = period.contains(RegExp(r'\d'))
      ? 'date'
      : (tr['type'] as String? ?? 'factual');

  return {
    'id': id,
    'question_ru': tr['question_de'],
    'question_de': tr['question_de'],
    'correct_answer_ru': correctDe,
    'correct_answer_de': correctDe,
    'wrong_answers_ru': wrongLetters.map((l) => deOpts[l]!).toList(),
    'wrong_answers_de': wrongLetters.map((l) => deOpts[l]!).toList(),
    'explanation_ru': tr['explanation_de'],
    'explanation_de': tr['explanation_de'],
    'interesting_facts': (tr['facts_de'] as List<dynamic>).map<Map<String, String>>((line) => {
              'ru': line.toString(),
              'de': line.toString(),
            }).toList(),
    'difficulty': tr['difficulty'] as String? ?? 'medium',
    'category': 'Древняя Греция',
    'type': type,
    'period': period,
    'tags': List<String>.from(tr['tags'] as List? ?? ['antike', 'import']),
  };
}

void main() async {
  final ruList = jsonDecode(File(_ruJson).readAsStringSync()) as List<dynamic>;
  final trMapRaw = jsonDecode(File(_deJson).readAsStringSync()) as Map<String, dynamic>;
  final existingFile = File(_targetJson);
  final existingRaw = jsonDecode(existingFile.readAsStringSync()) as List<dynamic>;
  final existingQNorms =
      existingRaw.map((row) => normQ(row['question_de'] as String)).toSet();

  int maxId = 0;
  for (final row in existingRaw) {
    final id = row['id'] as int?;
    if (id != null && id > maxId) maxId = id;
  }

  var added = 0;
  var skippedDup = 0;
  var skippedMissingTr = 0;
  var skippedRusDup = 0;

  final newRows = <Map<String, Object?>>[];

  for (final raw in ruList) {
    final ru = raw as Map<String, dynamic>;
    final normKey = ru['norm'] as String;
    if (_skipRusNormAlreadyInJson.contains(normKey)) {
      skippedRusDup++;
      continue;
    }
    final trDyn = trMapRaw[normKey];
    if (trDyn == null) {
      stderr.writeln('Missing translation for norm: $normKey');
      skippedMissingTr++;
      continue;
    }
    final tr = trDyn as Map<String, dynamic>;
    final qde = tr['question_de'] as String;
    final nDe = normQ(qde);
    if (existingQNorms.contains(nDe)) {
      skippedDup++;
      continue;
    }
    existingQNorms.add(nDe);
    maxId++;
    newRows.add(buildQuizEntry(id: maxId, ru: ru, tr: tr));
    added++;
  }

  existingRaw.addAll(newRows.map((x) => x));
  final encoder = JsonEncoder.withIndent('  ');
  await existingFile.writeAsString(encoder.convert(existingRaw));

  stderr.writeln('Added $added questions (next id ending at $maxId). '
      'Skipped $skippedDup GER duplicates, $skippedRusDup RU‑CSV overlaps, '
      '$skippedMissingTr missing translations.');
}
