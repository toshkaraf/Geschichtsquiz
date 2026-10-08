import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/services/german_tts_text.dart';

void main() {
  test('Jahreszahlen', () {
    expect(prepareGermanTts('Im Jahr 1914 begann'),
        'Im Jahr neunzehnhundert vierzehn begann');
    expect(prepareGermanTts('1900'), 'neunzehnhundert');
    expect(prepareGermanTts('1901'), 'neunzehnhundert eins');
    expect(prepareGermanTts('2024'), 'zweitausendvierundzwanzig');
    expect(prepareGermanTts('800 n. Chr.'), 'achthundert nach Christus');
  });

  test('Daten und Ordinalzahlen', () {
    expect(prepareGermanTts('am 12. März 1848'),
        'am zwölften März achtzehnhundert achtundvierzig');
    expect(prepareGermanTts('im 19. Jahrhundert'),
        'im neunzehnten Jahrhundert');
    expect(prepareGermanTts('Das 20. Jahrhundert'),
        'Das zwanzigste Jahrhundert');
    expect(prepareGermanTts('am 1.5.1945'),
        'am ersten fünften neunzehnhundert fünfundvierzig');
  });

  test('Bereiche, Jahrzehnte, sonstige Zahlen', () {
    expect(prepareGermanTts('1914–1918'),
        'neunzehnhundert vierzehn bis neunzehnhundert achtzehn');
    expect(prepareGermanTts('die 1920er Jahre'),
        'die neunzehnhundert zwanziger Jahre');
    expect(prepareGermanTts('1.500.000 Menschen'),
        'eine Million fünfhunderttausend Menschen');
    expect(prepareGermanTts('3,5 %'), 'drei Komma fünf Prozent');
    expect(prepareGermanTts('1 Jahr'), 'ein Jahr');
    expect(prepareGermanTts('Es waren 21.'), 'Es waren einundzwanzig.');
  });
}
