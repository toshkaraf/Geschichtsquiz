// Maps raw period strings from question JSON to canonical German epoch labels
// (European / German school-style antiquity + 19th/20th c. for Egyptology).

/// Chronological order for dropdowns (oldest → newest).
const List<String> kGermanEpochOrder = [
  'Urgeschichte',
  'Alte Hochkulturen',
  'Mittlere und späte Bronzezeit',
  'Frühe Eisenzeit und archaische Antike',
  'Klassische Antike',
  'Hellenismus und Römische Republik',
  'Römische Kaiserzeit',
  'Spätantike',
  'Mittelalter und Frühe Neuzeit',
  'Frühe Neuzeit',
  '19. Jahrhundert',
  '20. Jahrhundert',
  'Neuzeit (sonstige)', // fallback for unparseable strings only
];

class PeriodEpochMapper {
  PeriodEpochMapper._();

  /// Public entry: normalize any raw period string from JSON.
  static String mapRawPeriodToGermanEpoch(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return kGermanEpochOrder.last;
    }
    final y = _representativeYear(raw.trim());
    if (y == null) {
      return kGermanEpochOrder.last;
    }
    return _epochLabelForRepresentativeYear(y);
  }

  static int compareEpochLabels(String a, String b) {
    final ia = kGermanEpochOrder.indexOf(a);
    final ib = kGermanEpochOrder.indexOf(b);
    if (ia == -1 && ib == -1) return a.compareTo(b);
    if (ia == -1) return 1;
    if (ib == -1) return -1;
    return ia.compareTo(ib);
  }

  /// Representative year: BCE [n] → [-n], CE [n] → [n]; no astronomical year 0.
  static String _epochLabelForRepresentativeYear(int y) {
    if (y < -3000) return 'Urgeschichte';
    if (y < -1600) return 'Alte Hochkulturen';
    if (y < -800) return 'Mittlere und späte Bronzezeit';
    // End of „archaic“ ca. 530 v. Chr. (klassische Frühzeit ab ca. 500 v. Chr.)
    if (y < -530) return 'Frühe Eisenzeit und archaische Antike';
    if (y < -336) return 'Klassische Antike';
    // 27 v. Chr. = Beginn der Kaiserzeit (Prinzipat)
    if (y < -27) return 'Hellenismus und Römische Republik';
    if (y < 284) return 'Römische Kaiserzeit';
    if (y < 600) return 'Spätantike';
    if (y < 1450) return 'Mittelalter und Frühe Neuzeit';
    if (y < 1815) return 'Frühe Neuzeit';
    // Späte Aufklärung / Altertumswissenschaft (z. B. Rosetta 1799, Champollion 1822)
    if (y < 1900) return '19. Jahrhundert';
    if (y < 2000) return '20. Jahrhundert';
    return 'Neuzeit (sonstige)';
  }

  static int? _representativeYear(String s) {
    final norm = s
        .toLowerCase()
        .replaceAll('в.н.э.', 'ce')
        .replaceAll('н.э.', 'ce')
        .replaceAll('до н.э.', 'bce')
        .replaceAll('v. chr.', 'bce')
        .replaceAll('v.chr.', 'bce')
        .replaceAll('n. chr.', 'ce')
        .replaceAll('n.chr.', 'ce')
        .trim();

    // Plain CE year (archaeology / Egyptology)
    final plainYear = RegExp(r'^(\d{3,4})$').firstMatch(norm);
    if (plainYear != null) {
      return int.tryParse(plainYear.group(1)!);
    }

    // "8th century bce onwards"
    if (norm.contains('onwards')) {
      final before = norm.split('onwards').first.trim();
      final y0 = _parseSinglePhrase(before);
      return y0;
    }

    // Ranges with " - " (note spaces)
    if (norm.contains(' - ')) {
      final parts = norm.split(' - ').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final y1 = _parseSinglePhrase(parts[0]);
        final y2 = _parseSinglePhrase(parts[1]);
        if (y1 != null && y2 != null) {
          return _averageWithSpanGuard(y1, y2);
        }
        if (y1 != null) return y1;
        if (y2 != null) return y2;
      }
    }

    // Hyphen ranges without spaces: "3500-3000 bce", "8th-4th century bce"
    final hyphenCentury = RegExp(
      r'^(\d+)(?:st|nd|rd|th)\s*-\s*(\d+)(?:st|nd|rd|th)\s*century\s*(bce|ce)$',
    ).firstMatch(norm);
    if (hyphenCentury != null) {
      final o1 = int.parse(hyphenCentury.group(1)!);
      final o2 = int.parse(hyphenCentury.group(2)!);
      final era = hyphenCentury.group(3)!;
      final y1 = _centuryMidpoint(o1, era == 'bce');
      final y2 = _centuryMidpoint(o2, era == 'bce');
      if (y1 != null && y2 != null) {
        return _averageWithSpanGuard(y1, y2);
      }
    }

    final hyphenYearsBce = RegExp(r'^(\d+)\s*-\s*(\d+)\s*bce$').firstMatch(norm);
    if (hyphenYearsBce != null) {
      final a = -int.parse(hyphenYearsBce.group(1)!);
      final b = -int.parse(hyphenYearsBce.group(2)!);
      return _averageWithSpanGuard(a, b);
    }

    final hyphenYearsMixed = RegExp(r'^(\d+)\s*bce\s*-\s*(\d+)\s*ce$').firstMatch(norm);
    if (hyphenYearsMixed != null) {
      final a = -int.parse(hyphenYearsMixed.group(1)!);
      final b = int.parse(hyphenYearsMixed.group(2)!);
      return _averageWithSpanGuard(a, b);
    }

    final hyphenYearsCe = RegExp(r'^(\d+)\s*-\s*(\d+)\s*ce$').firstMatch(norm);
    if (hyphenYearsCe != null) {
      final a = int.parse(hyphenYearsCe.group(1)!);
      final b = int.parse(hyphenYearsCe.group(2)!);
      return _averageWithSpanGuard(a, b);
    }

    return _parseSinglePhrase(norm);
  }

  /// If the span is huge, weight toward the earlier (ancient) anchor so pharaonic-wide ranges do not land in the Middle Ages.
  static int _averageWithSpanGuard(int y1, int y2) {
    final lo = y1 < y2 ? y1 : y2;
    final hi = y1 < y2 ? y2 : y1;
    final span = hi - lo;
    if (span > 2200) {
      return lo + (span ~/ 4);
    }
    return ((lo + hi) / 2).round();
  }

  static int? _parseSinglePhrase(String phrase) {
    final p = phrase.trim();

    final ordCent = RegExp(
      r'^(\d{1,2})(?:st|nd|rd|th)\s*century\s*(bce|ce)$',
    ).firstMatch(p);
    if (ordCent != null) {
      final ord = int.parse(ordCent.group(1)!);
      return _centuryMidpoint(ord, ordCent.group(2) == 'bce');
    }

    final yearBce = RegExp(r'^(\d+)\s*bce$').firstMatch(p);
    if (yearBce != null) {
      return -int.parse(yearBce.group(1)!);
    }

    final yearCe = RegExp(r'^(\d+)\s*ce$').firstMatch(p);
    if (yearCe != null) {
      return int.parse(yearCe.group(1)!);
    }

    return null;
  }

  /// [ordinal]: 1 = 1st century; BCE midpoint for century k: -(100*k - 50). CE: (100*k - 50).
  static int? _centuryMidpoint(int ordinal, bool isBce) {
    if (ordinal < 1 || ordinal > 50) return null;
    if (isBce) return -(100 * ordinal - 50);
    return 100 * ordinal - 50;
  }
}
