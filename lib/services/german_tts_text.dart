/// Bereitet deutschen Text für die Sprachausgabe auf: Zahlen, Jahreszahlen,
/// Daten, Ordinalzahlen und gängige Abkürzungen werden ausgeschrieben, weil
/// System-Stimmen sie sonst oft falsch vorlesen.
library;

const _ones = [
  '', 'ein', 'zwei', 'drei', 'vier', 'fünf', 'sechs', 'sieben', 'acht', 'neun',
  'zehn', 'elf', 'zwölf', 'dreizehn', 'vierzehn', 'fünfzehn', 'sechzehn',
  'siebzehn', 'achtzehn', 'neunzehn',
];
const _tens = [
  '', '', 'zwanzig', 'dreißig', 'vierzig', 'fünfzig', 'sechzig', 'siebzig',
  'achtzig', 'neunzig',
];
const _digitWords = [
  'null', 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs', 'sieben', 'acht',
  'neun',
];

const _months =
    'Januar|Jänner|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|'
    'November|Dezember';

String _below100(int n) {
  if (n == 0) return '';
  if (n < 20) return _ones[n];
  final o = n % 10;
  final t = n ~/ 10;
  return o == 0 ? _tens[t] : '${_ones[o]}und${_tens[t]}';
}

String _below1000(int n) {
  final h = n ~/ 100;
  final r = n % 100;
  return '${h > 0 ? '${_ones[h]}hundert' : ''}${_below100(r)}';
}

/// Kardinalzahl mit Stamm „ein“ (z. B. „einhundert“); Endung „eins“ siehe [_withS].
String _card(int n) {
  if (n == 0) return 'null';
  final b = StringBuffer();
  final mil = n ~/ 1000000;
  final rest = n % 1000000;
  if (mil > 0) b.write(mil == 1 ? 'eine Million ' : '${_card(mil)} Millionen ');
  final th = rest ~/ 1000;
  final u = rest % 1000;
  if (th > 0) b.write('${_below1000(th)}tausend');
  if (u > 0) b.write(_below1000(u));
  return b.toString().trim();
}

String _withS(String s) => s.endsWith('ein') ? '${s}s' : s;

/// 1914 → „neunzehnhundert vierzehn“.
String _year(int y) {
  final h = y ~/ 100;
  final r = y % 100;
  return '${_below100(h)}hundert${r > 0 ? ' ${_withS(_below100(r))}' : ''}';
}

/// Ordinalzahl 1–99 ohne Deklination: 1 → „erste“, 19 → „neunzehnte“.
String _ordinal(int n, {bool dative = false}) {
  final String stem;
  switch (n) {
    case 1:
      stem = 'ers';
    case 3:
      stem = 'drit';
    case 7:
      stem = 'sieb';
    case 8:
      stem = 'ach';
    default:
      stem = n < 20 ? _card(n) : '${_card(n)}s';
  }
  return '${stem}te${dative ? 'n' : ''}';
}

String _speakDigits(String digits) =>
    digits.split('').map((d) => _digitWords[int.parse(d)]).join(' ');

String _number(String digits, {required bool followedByWord}) {
  final n = int.tryParse(digits);
  if (n == null || digits.length > 9 || (digits.length > 1 && digits[0] == '0')) {
    return _speakDigits(digits);
  }
  if (n >= 1100 && n <= 1999) return _year(n);
  final c = _card(n);
  return followedByWord ? c : _withS(c);
}

final _wordFollows = RegExp(r'^\s+[A-Za-zÄÖÜäöüß]');

String prepareGermanTts(String text) {
  var s = text;

  // Abkürzungen.
  const abbr = {
    r'\bv\.\s?Chr\.': 'vor Christus',
    r'\bn\.\s?Chr\.': 'nach Christus',
    r'\bz\.\s?B\.': 'zum Beispiel',
    r'\bd\.\s?h\.': 'das heißt',
    r'\bu\.\s?a\.': 'unter anderem',
    r'\bbzw\.': 'beziehungsweise',
    r'\busw\.': 'und so weiter',
    r'\bca\.': 'circa',
    r'\bJh\.': 'Jahrhundert',
    r'\bNr\.': 'Nummer',
  };
  abbr.forEach((pattern, word) {
    s = s.replaceAll(RegExp(pattern), word);
  });

  // Volles Datum 12.3.1848.
  s = s.replaceAllMapped(RegExp(r'\b(\d{1,2})\.(\d{1,2})\.(\d{4})\b'), (m) {
    final d = int.parse(m[1]!);
    final mo = int.parse(m[2]!);
    if (d < 1 || d > 31 || mo < 1 || mo > 12) return m[0]!;
    return '${_ordinal(d, dative: true)} ${_ordinal(mo, dative: true)} '
        '${_number(m[3]!, followedByWord: false)}';
  });

  // Jahrzehnte: 1920er, 60er.
  s = s.replaceAllMapped(RegExp(r'\b(\d{2,4})er\b'), (m) {
    final n = int.parse(m[1]!);
    final base = (n >= 1100 && n <= 1999) ? _year(n) : _card(n);
    return '${base}er';
  });

  // Ordinalzahlen vor Monat / Jahrhundert / Weltkrieg.
  s = s.replaceAllMapped(
    RegExp(
      r'(\b(?:[Dd]as|[Dd]er|[Dd]ie|[Dd]ieses|[Dd]ieser|[Ee]in|[Ee]ine)\s+)?'
      r'\b(\d{1,2})\.\s+(?=(?:' + _months + r'|Jahrhundert|Jahrtausend|Weltkrieg))',
    ),
    (m) {
      final n = int.parse(m[2]!);
      return '${m[1] ?? ''}${_ordinal(n, dative: m[1] == null)} ';
    },
  );

  // Bereiche: 1914–1918, 1914-18.
  s = s.replaceAllMapped(RegExp(r'\b(\d{3,4})\s*[–—-]\s*(\d{2,4})\b'), (m) {
    var b = m[2]!;
    if (m[1]!.length == 4 && b.length == 2) b = m[1]!.substring(0, 2) + b;
    return '${m[1]} bis $b';
  });

  // Prozent.
  s = s.replaceAllMapped(RegExp(r'(\d)\s*%'), (m) => '${m[1]} Prozent');

  // Tausenderpunkte: 1.500.000 → 1500000.
  s = s.replaceAllMapped(
    RegExp(r'\b\d{1,3}(?:\.\d{3})+\b'),
    (m) => m[0]!.replaceAll('.', ''),
  );

  // Dezimalzahlen: 3,5 → drei Komma fünf.
  s = s.replaceAllMapped(RegExp(r'\b(\d+),(\d+)\b'), (m) {
    return '${_number(m[1]!, followedByWord: true)} Komma ${_speakDigits(m[2]!)}';
  });

  // Übrige Zahlen.
  s = s.replaceAllMapped(RegExp(r'\d+'), (m) {
    final follows = _wordFollows.hasMatch(m.input.substring(m.end));
    return _number(m[0]!, followedByWord: follows);
  });

  return s;
}
