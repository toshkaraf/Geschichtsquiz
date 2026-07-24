// dart run tools/import_voprosy_txt.dart [--emit-ru-json path]
//
// Parses C:\Users\Envy x360\Downloads\вопросы.txt style blocks:
//   N. question
//   Варианты:
//   а) ..
//   Правильный ответ: б) Foo
//   Справочный ответ:
//   ... body ...
//   Интересные факты:
//   ... up to blank line paragraphs until next numbered question ...

import 'dart:convert';
import 'dart:io';

const _defaultInput =
    r'C:\Users\Envy x360\Downloads\вопросы.txt';

void main(List<String> args) async {
  final inputPath = args.isNotEmpty && !args.first.startsWith('--')
      ? args.first
      : _defaultInput;
  bool emitRu = false;
  String? ruOutPath;
  for (final a in args) {
    if (a == '--emit-ru-json' && args.length > args.indexOf(a) + 1) {
      emitRu = true;
      ruOutPath = args[args.indexOf(a) + 1];
    }
  }

  final file = File(inputPath);
  if (!await file.exists()) {
    stderr.writeln('File not found: $inputPath');
    exit(1);
  }
  final lines = await file.readAsLines(encoding: utf8);
  final items = parseVoprosyLines(lines);

  stderr.writeln('Parsed ${items.length} complete quiz items.');
  if (emitRu && ruOutPath != null) {
    await File(ruOutPath).writeAsString(
      JsonEncoder.withIndent('  ').convert(
        items.map((e) => e.toJsonRu()).toList(),
      ),
    );
    stderr.writeln('Wrote ${items.length} RU stubs to $ruOutPath');
  }

  stdout.writeln(JsonEncoder.withIndent('  ').convert(
    items.map((e) => e.toJsonRu()).toList(),
  ));
}

/// Normalizes for dedupe: lowercase, squeeze spaces.
String normKey(String s) {
  return s.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
}

class ParsedRuQuiz {
  ParsedRuQuiz({
    required this.number,
    required this.question,
    required this.options,
    required this.correctLetter,
    required this.correctText,
    required this.explanation,
    required this.facts,
  });

  final int number;
  final String question;
  /// Keys: а, б, в, г
  final Map<String, String> options;
  final String correctLetter;
  final String correctText;
  final String explanation;
  final List<String> facts;

  Map<String, Object?> toJsonRu() => {
        'source_number': number,
        'question': question,
        'options': options,
        'correct_letter': correctLetter,
        'correct_text': correctText,
        'explanation': explanation,
        'facts': facts,
        'norm': normKey(question),
      };
}

final _qStart = RegExp(r'^(\d+)\.\s+(.+)\s*$');
final _correctLine =
    RegExp(r'^Правильный\s+ответ:\s*([абвг])\)\s*(.+?)\s*$', caseSensitive: false);
final _variantLine =
    RegExp(r'^\s*([абвг])\)\s*(.+)\s*$', caseSensitive: false);

List<ParsedRuQuiz> parseVoprosyLines(List<String> lines) {
  final out = <ParsedRuQuiz>[];
  var i = 0;

  Map<String, String>? opts;
  String? correctLetterMarked;
  int? qNum;
  String? qText;
  final bufExplanation = StringBuffer();
  final bufFacts = <StringBuffer>[];

  Mode mode = Mode.huntQuestion;

  void flushIncomplete() {
    opts = null;
    correctLetterMarked = null;
    qNum = null;
    qText = null;
    bufExplanation.clear();
    bufFacts.clear();
    mode = Mode.huntQuestion;
  }

  void tryCommit() {
    if (opts == null || qNum == null || qText == null) {
      flushIncomplete();
      return;
    }
    final letter = correctLetterMarked;
    if (letter == null || !opts!.containsKey(letter)) {
      stderr.writeln('Skip #$qNum: broken correct answer linkage.');
      flushIncomplete();
      return;
    }
    if (opts!.length != 4) {
      stderr.writeln('Skip #$qNum: expected 4 options, got ${opts!.length}.');
      flushIncomplete();
      return;
    }
    final corrText = opts![letter]!;
    final wrongOrdered = ['а', 'б', 'в', 'г'].where((x) => x != letter).toList();
    if (wrongOrdered.length != 3) {
      flushIncomplete();
      return;
    }

    final expl = bufExplanation.toString().trim();
    final facts =
        bufFacts.map((sb) => sb.toString().trim()).where((s) => s.isNotEmpty).toList();

    if (expl.isEmpty || facts.length < 3) {
      stderr.writeln(
          'Skip #$qNum: missing explanation or fewer than 3 facts (facts=${facts.length}).');
      flushIncomplete();
      return;
    }

    out.add(ParsedRuQuiz(
      number: qNum!,
      question: qText!,
      options: Map<String, String>.from(opts!),
      correctLetter: letter,
      correctText: corrText,
      explanation: expl,
      facts: facts.take(3).toList(),
    ));
    flushIncomplete();
  }

  while (i < lines.length) {
    final raw = lines[i];
    final line = raw.trimRight();

    // Noise / headings
    if (line.startsWith('Файл ') ||
        line.startsWith('Ниже') ||
        line.contains('продолжай') ||
        line.contains('продолжу') ||
        line == 'далее по мере расширения' ||
        line.startsWith('Часть ') ||
        line.startsWith('Каждый вопрос') ||
        line.startsWith('Для удобства') ||
        line.startsWith('краткий справочный') ||
        line.startsWith('3 интересных') ||
        line.startsWith('Каждому.') ||
        line.startsWith('текст') ||
        line.isEmpty && mode == Mode.huntQuestion && qNum == null) {
      i++;
      continue;
    }

    final mq = _qStart.firstMatch(line);
    if (mq != null &&
        !(line.startsWith(RegExp(r'Файл')))) {
      tryCommit();
      qNum = int.parse(mq.group(1)!);
      qText = mq.group(2)!.trim();
      opts = {};
      bufExplanation.clear();
      bufFacts.clear();
      mode = Mode.afterQuestion;
      i++;
      continue;
    }

    switch (mode) {
      case Mode.huntQuestion:
        i++;
        break;
      case Mode.afterQuestion:
        if (line.trim() == 'Варианты:') {
          mode = Mode.options;
        }
        i++;
        break;
      case Mode.options:
        final vm = _variantLine.firstMatch(line);
        if (vm != null) {
          opts![vm.group(1)!] = vm.group(2)!.trim();
          i++;
          break;
        }
        final pc = _correctLine.firstMatch(line);
        if (pc != null) {
          correctLetterMarked = pc.group(1)!.toLowerCase();
          mode = Mode.awaitExplanationHeader;
          i++;
          break;
        }
        if (line.startsWith('Справочный ответ')) {
          mode = Mode.explanationBody;
          i++;
          break;
        }
        // junk between options — skip line
        i++;
        break;
      case Mode.awaitExplanationHeader:
        if (line.startsWith('Справочный')) {
          mode = Mode.explanationBody;
          i++;
          break;
        }
        i++;
        break;
      case Mode.explanationBody:
        if (line.startsWith('Интересные факты')) {
          mode = Mode.factsBlankOrBody;
          i++;
          break;
        }
        if (line.trim().isNotEmpty) bufExplanation.writeln(line);
        i++;
        break;
      case Mode.factsBlankOrBody:
        if (_qStart.hasMatch(line)) {
          tryCommit();
          continue;
        }
        if (line.trim().isEmpty) {
          i++;
          mode = Mode.factsBodyPara;
          break;
        }
        bufFacts.add(StringBuffer(line));
        i++;
        mode = Mode.factsBodyPara;
        break;
      case Mode.factsBodyPara:
        if (_qStart.hasMatch(line)) {
          tryCommit();
          continue;
        }
        if (line.trim().isEmpty) {
          if (bufFacts.isNotEmpty &&
              bufFacts.last.toString().trim().split('\n').join('').isNotEmpty) {
            bufFacts.add(StringBuffer());
          }
          i++;
          break;
        }
        if (bufFacts.isEmpty) bufFacts.add(StringBuffer());
        if (bufFacts.isNotEmpty &&
            bufFacts.last.toString().trim().startsWith(RegExp(r'^(а|б|в|г)\)'))) {
          // Should not happen often
          bufFacts.add(StringBuffer());
        }
        if (bufFacts.isNotEmpty) {
          final last = bufFacts.last;
          if (last.isNotEmpty) last.writeln();
          last.write(line);
        }
        i++;
        break;
    }
  }

  tryCommit();

  return dedupeByQuestion(out);
}

List<ParsedRuQuiz> dedupeByQuestion(List<ParsedRuQuiz> list) {
  final seen = <String>{};
  final res = <ParsedRuQuiz>[];
  for (final q in list) {
    final k = normKey(q.question);
    if (seen.contains(k)) continue;
    seen.add(k);
    res.add(q);
  }
  return res;
}

enum Mode {
  huntQuestion,
  afterQuestion,
  options,
  awaitExplanationHeader,
  explanationBody,
  factsBlankOrBody,
  factsBodyPara,
}
