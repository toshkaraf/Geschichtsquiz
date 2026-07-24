#!/usr/bin/env python3
"""Generate early modern quiz JSON (IDs 7001+) from ODT source + German translations."""
import json
import re
from pathlib import Path

RU_PATH = Path(__file__).parent / "fragen_odt_clean_ru.json"
OUT_PATH = (
    Path(__file__).parent.parent
    / "lib/data/Fragen/Detailed/early_modern_7001_7047.json"
)

# German translations keyed by source_id from Fragen.odt
DE: dict[int, dict] = {
    1: {
        "question_de": "In welchem Jahrhundert gilt traditionell der Beginn der Frühen Neuzeit in Europa?",
        "options_de": ["10. Jh.", "14. Jh.", "16. Jh.", "19. Jh."],
        "correct_de": "16. Jh.",
        "explanation_de": "Das 16. Jahrhundert gilt als Beginn der Frühen Neuzeit, als große politische und religiöse Umbrüche Europa prägten.",
        "facts_de": [
            "In dieser Zeit beginnt die Reformation und breitet sich der Buchdruck aus.",
            "Viele Staaten gehen zu stärker zentralisierter Herrschaft über.",
            "Die Epoche eröffnet neue Handelswege und maritime Expeditionen.",
        ],
        "period": "1550 CE",
        "tags": ["Frühe Neuzeit", "Epochen"],
        "difficulty": "easy",
    },
    2: {
        "question_de": "Welches Ereignis des Jahres 1517 gilt als Beginn der Reformation in Europa?",
        "options_de": [
            "Kreuzzug",
            "Veröffentlichung der 95 Thesen Luthers",
            "Fall Konstantinopels",
            "Entdeckung Amerikas",
        ],
        "correct_de": "Veröffentlichung der 95 Thesen Luthers",
        "explanation_de": "Martin Luther veröffentlichte 1517 seine 95 Thesen gegen den Ablasshandel – der Ausgangspunkt der protestantischen Reformation.",
        "facts_de": [
            "Das Ereignis führte zum Bruch innerhalb der katholischen Kirche.",
            "Die Reformation veränderte die religiöse Landkarte Europas grundlegend.",
            "Der Buchdruck half, Luthers Schriften schnell zu verbreiten.",
        ],
        "period": "1517 CE",
        "tags": ["Reformation", "Luther"],
        "difficulty": "easy",
    },
    3: {
        "question_de": "Welcher Krieg von 1562–1598 in Frankreich war mit religiösen Konflikten zwischen Katholiken und Protestanten verbunden?",
        "options_de": [
            "Hundertjähriger Krieg",
            "Rosenkriege",
            "Hugenottenkriege",
            "Dreißigjähriger Krieg",
        ],
        "correct_de": "Hugenottenkriege",
        "explanation_de": "Die Hugenottenkriege (französische Religionskriege) wurden zwischen Katholiken und protestantischen Hugenotten ausgetragen.",
        "facts_de": [
            "Die Kriege gingen mit Massakern und Plünderungen einher.",
            "Am Ende erhielten die Hugenotten teilweise religiöse Freiheit.",
            "Der Edikt von Nantes von 1598 beendete die offiziellen Religionskriege.",
        ],
        "period": "1580 CE",
        "tags": ["Frankreich", "Religion"],
        "difficulty": "medium",
    },
    11: {
        "question_de": "In welchem Jahr erreichte Christoph Kolumbus Amerika und eröffnete einen neuen Handelsweg zwischen Europa und der Neuen Welt?",
        "options_de": ["1492", "1500", "1498", "1510"],
        "correct_de": "1492",
        "explanation_de": "Kolumbus erreichte 1492 Amerika und leitete die europäische Erschließung der Neuen Welt ein.",
        "facts_de": [
            "Das Ereignis veränderte Handelskarten und geografisches Wissen.",
            "Europa gewann Zugang zu neuen Ressourcen und Kulturen.",
            "Die Expedition war vom spanischen Königshaus finanziert worden.",
        ],
        "period": "1492 CE",
        "tags": ["Kolonialismus", "Entdeckungen"],
        "difficulty": "easy",
    },
    12: {
        "question_de": "Welche Macht begann im 16. Jahrhundert als erste die groß angelegte Kolonisierung Amerikas?",
        "options_de": ["Frankreich", "Spanien", "Portugal", "England"],
        "correct_de": "Spanien",
        "explanation_de": "Spanien begann im 16. Jahrhundert die erste groß angelegte Kolonisierung Amerikas nach der Eroberung Mexikos und Perus.",
        "facts_de": [
            "Spanische Kolonien lieferten Gold und Silber nach Europa.",
            "Die Kolonisierung ging mit der Zerstörung einheimischer Kulturen einher.",
            "Die spanische Kirche war eng in die Kolonialherrschaft eingebunden.",
        ],
        "period": "1550 CE",
        "tags": ["Spanien", "Kolonialismus"],
        "difficulty": "easy",
    },
    13: {
        "question_de": "Welches Ereignis von 1555 teilte in Europa offiziell Christenheit in Katholiken und Protestanten?",
        "options_de": [
            "Augsburger Religionsfrieden",
            "Edikt von Nantes",
            "Wormser Reichstag",
            "Tridentinisches Konzil",
        ],
        "correct_de": "Augsburger Religionsfrieden",
        "explanation_de": "Der Augsburger Religionsfrieden von 1555 legte in Deutschland die religiöse Teilung zwischen Katholiken und Protestanten fest.",
        "facts_de": [
            "Jeder Fürst durfte die Konfession seiner Untertanen bestimmen.",
            "Der Frieden wurde zur wichtigen Grundlage religiöser Kompromisse.",
            "Er schwächte den Einfluss der katholischen Kirche in Nordeuropa.",
        ],
        "period": "1555 CE",
        "tags": ["Reformation", "Deutschland"],
        "difficulty": "medium",
    },
    14: {
        "question_de": "In welchem Jahrhundert begann die Epoche der großen geografischen Entdeckungen?",
        "options_de": ["15. Jh.", "16. Jh.", "14. Jh.", "17. Jh."],
        "correct_de": "15. Jh.",
        "explanation_de": "Die großen geografischen Entdeckungen begannen im 15. Jahrhundert mit Expeditionen Portugals und Spaniens.",
        "facts_de": [
            "Portugal erschloss den Seeweg nach Indien um Afrika.",
            "Spanien entdeckte Amerika und die Philippinen.",
            "Die Entdeckungen führten zu globalem Handel und Kolonisierung.",
        ],
        "period": "1475 CE",
        "tags": ["Entdeckungen", "Seefahrt"],
        "difficulty": "easy",
    },
    15: {
        "question_de": "Welches Land eröffnete als erstes den Seeweg nach Indien um Afrika?",
        "options_de": ["Spanien", "Portugal", "Frankreich", "England"],
        "correct_de": "Portugal",
        "explanation_de": "Portugal eröffnete Ende des 15. Jahrhunderts den Seeweg nach Indien um Afrika.",
        "facts_de": [
            "Vasco da Gama erreichte Indien 1498.",
            "Der Weg ermöglichte portugiesische Kontrolle über den Gewürzhandel.",
            "Portugal baute Kolonien in Indien und Afrika auf.",
        ],
        "period": "1498 CE",
        "tags": ["Portugal", "Indien"],
        "difficulty": "easy",
    },
    16: {
        "question_de": "Welches Kulturphänomen des 16. Jahrhunderts in Europa ist mit der Wiederbelebung antiker Ideen und der Kunstentwicklung verbunden?",
        "options_de": ["Reformation", "Barock", "Renaissance", "Humanismus"],
        "correct_de": "Renaissance",
        "explanation_de": "Die Renaissance im 16. Jahrhundert verband die Wiederbelebung antiker Ideen mit einem Höhepunkt der Kunst.",
        "facts_de": [
            "In dieser Zeit wirkten Leonardo da Vinci, Michelangelo und Raffael.",
            "Fürstenhöfe förderten Kunst und Wissenschaft gleichermaßen.",
            "Die Renaissance prägte auch Architektur und Literatur.",
        ],
        "period": "1550 CE",
        "tags": ["Renaissance", "Kultur"],
        "difficulty": "easy",
    },
    17: {
        "question_de": "Welcher spanische Herrscher des 16. Jahrhunderts kontrollierte riesige Gebiete in Europa und Amerika?",
        "options_de": ["Karl I.", "Philipp II.", "Isabella I.", "Ferdinand II."],
        "correct_de": "Philipp II.",
        "explanation_de": "Philipp II. von Spanien beherrschte ein Weltreich mit Spanien, den Niederlanden und Kolonien in der Neuen Welt.",
        "facts_de": [
            "Er kämpfte gegen Protestanten und stützte die katholische Kirche.",
            "Sein Reich galt als eine der größten Monarchien Europas.",
            "Philipp II. regierte von 1556 bis 1598.",
        ],
        "period": "1580 CE",
        "tags": ["Spanien", "Monarchie"],
        "difficulty": "medium",
    },
    18: {
        "question_de": "Welches Ereignis von 1588 wurde zum Wendepunkt im Kampf zwischen England und Spanien?",
        "options_de": [
            "Fall Konstantinopels",
            "Niederlage der spanischen Armada",
            "Entdeckung Amerikas",
            "Reformation",
        ],
        "correct_de": "Niederlage der spanischen Armada",
        "explanation_de": "1588 wurde die spanische Armada von englischen und niederländischen Schiffen in der Kanalregion geschlagen.",
        "facts_de": [
            "Das Ereignis schwächte Spaniens Einfluss in Nordeuropa.",
            "England baute daraufhin seine Seemacht weiter aus.",
            "Der Sieg war ein Schritt zur späteren britischen Vorherrschaft zur See.",
        ],
        "period": "1588 CE",
        "tags": ["England", "Spanien"],
        "difficulty": "medium",
    },
    19: {
        "question_de": "In welchem Jahrhundert begann die Kolonisierung Amerikas durch europäische Mächte?",
        "options_de": ["15. Jh.", "16. Jh.", "14. Jh.", "17. Jh."],
        "correct_de": "16. Jh.",
        "explanation_de": "Die Kolonisierung Amerikas begann im 16. Jahrhundert mit spanischen und portugiesischen Expeditionen.",
        "facts_de": [
            "Spanien gründete Kolonien in Mexiko und Peru.",
            "Portugal kolonisierte Brasilien.",
            "Die Kolonisierung veränderte Bevölkerung und Ressourcen weltweit.",
        ],
        "period": "1550 CE",
        "tags": ["Kolonialismus", "Amerika"],
        "difficulty": "easy",
    },
    20: {
        "question_de": "Welche Macht wurde im 17. Jahrhundert zum Hauptrivalen Englands in Seefahrt und Kolonisation?",
        "options_de": ["Frankreich", "Spanien", "Portugal", "Niederlande"],
        "correct_de": "Niederlande",
        "explanation_de": "Die Niederlande wurden im 17. Jahrhundert zum wichtigsten Rivalen Englands in Seefahrt und Kolonisation.",
        "facts_de": [
            "Sie kontrollierten den Gewürzhandel und ein koloniales Netzwerk.",
            "Niederländische Kolonien entstanden in Asien und Amerika.",
            "Die Rivalität führte zu mehreren Seekriegen.",
        ],
        "period": "1650 CE",
        "tags": ["Niederlande", "Kolonialismus"],
        "difficulty": "medium",
    },
    191: {
        "question_de": "Welcher Krieg von 1689–1697 in Europa war mit dem Kampf zwischen England und Frankreich um Kolonialherrschaft verbunden?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Pfälzischer Erbfolgekrieg",
            "Siebenjähriger Krieg",
            "Spanischer Erbfolgekrieg",
        ],
        "correct_de": "Pfälzischer Erbfolgekrieg",
        "explanation_de": "Der Pfälzische Erbfolgekrieg wurde zwischen England, den Niederlanden und Frankreich um Einfluss in Europa und den Kolonien geführt.",
        "facts_de": [
            "Der Konflikt führte zu neuen Grenzziehungen in Europa.",
            "England stärkte seine Position in Nordamerika.",
            "Der Krieg war Teil der langen anglo-französischen Rivalität.",
        ],
        "period": "1693 CE",
        "tags": ["Kriege", "Kolonialismus"],
        "difficulty": "hard",
    },
    192: {
        "question_de": "Welche Macht gründete im 17. Jahrhundert die VOC und kontrollierte den Gewürzhandel in Asien?",
        "options_de": ["Spanien", "Portugal", "Niederlande", "Frankreich"],
        "correct_de": "Niederlande",
        "explanation_de": "Die Niederlande gründeten die Ostindien-Kompanie (VOC), die den asiatischen Gewürzhandel dominierte.",
        "facts_de": [
            "Die VOC gilt als eine der ersten Aktiengesellschaften der Welt.",
            "Niederländische Kolonien entstanden in Indien und Indonesien.",
            "Der Gewürzhandel brachte enorme Gewinne.",
        ],
        "period": "1650 CE",
        "tags": ["VOC", "Handel"],
        "difficulty": "medium",
    },
    193: {
        "question_de": "In welchem Jahrhundert begann in Europa die Epoche des Absolutismus?",
        "options_de": ["15. Jh.", "16. Jh.", "17. Jh.", "18. Jh."],
        "correct_de": "17. Jh.",
        "explanation_de": "Der Absolutismus begann im 17. Jahrhundert mit der Stärkung der königlichen Macht in vielen Staaten.",
        "facts_de": [
            "Monarchen konzentrierten politische Entscheidungen auf sich.",
            "Der Absolutismus wurde in mehreren Ländern zur Herrschaftsform.",
            "Er förderte die Zentralisierung der Staaten.",
        ],
        "period": "1650 CE",
        "tags": ["Absolutismus", "Monarchie"],
        "difficulty": "medium",
    },
    194: {
        "question_de": "Welcher französische Herrscher des 17. Jahrhunderts galt als „Sonnenkönig“ und schuf eine der mächtigsten Monarchien Europas?",
        "options_de": ["Ludwig XIII.", "Ludwig XIV.", "Ludwig XV.", "Heinrich IV."],
        "correct_de": "Ludwig XIV.",
        "explanation_de": "Ludwig XIV., der „Sonnenkönig“, baute eine der mächtigsten Monarchien Europas und ein System des Absolutismus auf.",
        "facts_de": [
            "Er konzentrierte die Staatsmacht am Hof von Versailles.",
            "Seine Regierung prägte Frankreich über ein halbes Jahrhundert.",
            "Ludwig XIV. regierte von 1643 bis 1715.",
        ],
        "period": "1680 CE",
        "tags": ["Frankreich", "Absolutismus"],
        "difficulty": "easy",
    },
    195: {
        "question_de": "Welcher Krieg von 1701–1714 in Europa drehte sich um die spanische Thronfolge?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Spanischer Erbfolgekrieg",
            "Siebenjähriger Krieg",
            "Pfälzischer Erbfolgekrieg",
        ],
        "correct_de": "Spanischer Erbfolgekrieg",
        "explanation_de": "Der Spanische Erbfolgekrieg wurde zwischen europäischen Mächten um den Einfluss auf Spanien ausgetragen.",
        "facts_de": [
            "Der Konflikt veränderte die Machtverhältnisse in Europa.",
            "England und die Niederlande gewannen an Stärke.",
            "Der Krieg war Teil der Rivalität um die europäische Hegemonie.",
        ],
        "period": "1707 CE",
        "tags": ["Kriege", "Spanien"],
        "difficulty": "medium",
    },
    201: {
        # Period >= 1450 so curriculum routes to Frühe Neuzeit (bridge topic from source file).
        "period": "1550 CE",
        "question_de": "Welches Dokument von 1215 in England beschränkte die Königsmacht und wurde Grundlage des Parlamentarismus?",
        "options_de": [
            "Magna Carta",
            "Act of Supremacy",
            "Bill of Rights",
            "Reformakt",
        ],
        "correct_de": "Magna Carta",
        "explanation_de": "Die Magna Carta von 1215 beschränkte die Macht König Johns und schützte Rechte der Barone.",
        "facts_de": [
            "Sie gilt als wichtige Grundlage des englischen Parlamentarismus.",
            "Die Charta sicherte Rechte auf faires Gericht.",
            "Sie beeinflusste die Entwicklung des Verfassungsrechts.",
        ],
        "tags": ["England", "Recht"],
        "difficulty": "medium",
    },
    202: {
        "period": "1550 CE",
        "question_de": "Welcher Krieg von 1337–1453 wurde in Europa zwischen England und Frankreich geführt?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Hundertjähriger Krieg",
            "Siebenjähriger Krieg",
            "Spanischer Erbfolgekrieg",
        ],
        "correct_de": "Hundertjähriger Krieg",
        "explanation_de": "Der Hundertjährige Krieg wurde zwischen England und Frankreich um Territorien ausgetragen.",
        "facts_de": [
            "Der Konflikt stärkte die französische Monarchie.",
            "England verlor fast alle Besitzungen in Frankreich.",
            "Der Krieg förderte die Entwicklung nationaler Staaten.",
        ],
        "tags": ["Frankreich", "England"],
        "difficulty": "medium",
    },
    203: {
        "question_de": "Welche Macht eröffnete im 15. Jahrhundert den Seeweg nach Indien um Afrika?",
        "options_de": ["Spanien", "Portugal", "Frankreich", "England"],
        "correct_de": "Portugal",
        "explanation_de": "Portugal eröffnete Ende des 15. Jahrhunderts den Seeweg nach Indien um Afrika.",
        "facts_de": [
            "Vasco da Gama erreichte Indien 1498.",
            "Der Weg sicherte portugiesische Kontrolle über Gewürze.",
            "Portugal baute Kolonien in Indien und Afrika auf.",
        ],
        "period": "1498 CE",
        "tags": ["Portugal", "Indien"],
        "difficulty": "easy",
    },
    204: {
        "question_de": "Welcher französische Herrscher des 16. Jahrhunderts stärkte den Katholizismus und unterdrückte Protestantismus?",
        "options_de": ["Franz I.", "Karl IX.", "Ludwig XIV.", "Heinrich IV."],
        "correct_de": "Franz I.",
        "explanation_de": "Franz I. stärkte im 16. Jahrhundert den Katholizismus und unterdrückte protestantische Bewegungen in Frankreich.",
        "facts_de": [
            "Er führte Kriege gegen das Reich und stützte die Kirche.",
            "Seine Regierung war von religiösen Konflikten geprägt.",
            "Franz I. wurde zum Symbol katholischer Königsmacht.",
        ],
        "period": "1550 CE",
        "tags": ["Frankreich", "Religion"],
        "difficulty": "medium",
    },
    205: {
        "question_de": "Welcher Krieg von 1618–1648 war der größte religiöse und politische Konflikt der Frühen Neuzeit in Europa?",
        "options_de": [
            "Hundertjähriger Krieg",
            "Dreißigjähriger Krieg",
            "Siebenjähriger Krieg",
            "Spanischer Erbfolgekrieg",
        ],
        "correct_de": "Dreißigjähriger Krieg",
        "explanation_de": "Der Dreißigjährige Krieg zwischen Katholiken und Protestanten verwüstete große Teile Mitteleuropas.",
        "facts_de": [
            "Er endete mit dem Westfälischen Frieden von 1648.",
            "Der Krieg veränderte die politische Landkarte Europas.",
            "Viele europäische Mächte waren direkt beteiligt.",
        ],
        "period": "1633 CE",
        "tags": ["Dreißigjähriger Krieg", "Deutschland"],
        "difficulty": "medium",
    },
    206: {
        "question_de": "Welcher Frieden von 1648 beendete den Dreißigjährigen Krieg und festigte die religiöse Teilung Europas?",
        "options_de": [
            "Augsburger Religionsfrieden",
            "Westfälischer Frieden",
            "Edikt von Nantes",
            "Friede von Paris",
        ],
        "correct_de": "Westfälischer Frieden",
        "explanation_de": "Der Westfälische Frieden von 1648 beendete den Dreißigjährigen Krieg und bestätigte religiöse und politische Souveränität vieler Staaten.",
        "facts_de": [
            "Er gilt als Grundlage des modernen Völkerrechts.",
            "Der Frieden schwächte die politische Rolle der katholischen Kirche.",
            "Das westfälische System prägte das europäische Staatensystem.",
        ],
        "period": "1648 CE",
        "tags": ["Westfälischer Frieden", "Frieden"],
        "difficulty": "medium",
    },
    207: {
        "question_de": "Welche Revolution von 1642–1651 in England führte zur Republik und zur Hinrichtung des Königs?",
        "options_de": [
            "Glorreiche Revolution",
            "Englische Revolution",
            "Französische Revolution",
            "Kreuzzug",
        ],
        "correct_de": "Englische Revolution",
        "explanation_de": "Die Englische Revolution führte zur Hinrichtung König Karls I. und zur kurzzeitigen Republik unter Oliver Cromwell.",
        "facts_de": [
            "Der Konflikt wurde zwischen Parlament und Krone ausgetragen.",
            "Oliver Cromwell wurde zum führenden Republikaner.",
            "Die Revolution veränderte das politische System Englands.",
        ],
        "period": "1646 CE",
        "tags": ["England", "Revolution"],
        "difficulty": "medium",
    },
    208: {
        "question_de": "Welche Macht wurde im 17. Jahrhundert zum Zentrum des Kolonialhandels und der Seemacht?",
        "options_de": ["Spanien", "Portugal", "Niederlande", "Frankreich"],
        "correct_de": "Niederlande",
        "explanation_de": "Im 17. Jahrhundert wurden die Niederlande zum Zentrum des Kolonialhandels und einer mächtigen Flotte.",
        "facts_de": [
            "Die VOC wurde zu einem Schlüsselinstrument des Handels.",
            "Niederländische Kolonien lagen vor allem in Asien.",
            "Ihre Flotte gehörte zu den stärksten der Welt.",
        ],
        "period": "1650 CE",
        "tags": ["Niederlande", "Handel"],
        "difficulty": "medium",
    },
    211: {
        "question_de": "Welche Revolution von 1789 in Europa wurde zum Symbol des Kampfes für Freiheit und Gleichheit?",
        "options_de": [
            "Englische Revolution",
            "Glorreiche Revolution",
            "Französische Revolution",
            "Amerikanische Revolution",
        ],
        "correct_de": "Französische Revolution",
        "explanation_de": "Die Französische Revolution von 1789 wurde zum Symbol für Freiheit, Gleichheit und Brüderlichkeit.",
        "facts_de": [
            "Sie führte zum Sturz der Monarchie und zur Republik.",
            "Die Revolution veränderte die politische Landkarte Europas.",
            "Ihre Ideen wirkten weit über Frankreich hinaus.",
        ],
        "period": "1789 CE",
        "tags": ["Französische Revolution", "Revolution"],
        "difficulty": "easy",
    },
    213: {
        "question_de": "In welchem Jahrhundert begann in Europa die Epoche der Reformation?",
        "options_de": ["14. Jh.", "15. Jh.", "16. Jh.", "17. Jh."],
        "correct_de": "16. Jh.",
        "explanation_de": "Die Reformation begann im 16. Jahrhundert mit Luthers 95 Thesen von 1517.",
        "facts_de": [
            "Die Reformation spaltete die westliche Christenheit.",
            "Viele Länder nahmen das Protestantismus an.",
            "Sie veränderte religiöse und politische Verhältnisse.",
        ],
        "period": "1517 CE",
        "tags": ["Reformation", "Religion"],
        "difficulty": "easy",
    },
    214: {
        "question_de": "Welche Macht kontrollierte im 16. Jahrhundert riesige Gebiete in Europa und Amerika und galt als Reich, „über dem die Sonne niemals untergeht“?",
        "options_de": ["Spanien", "Portugal", "Frankreich", "England"],
        "correct_de": "Spanien",
        "explanation_de": "Spanien beherrschte im 16. Jahrhundert ein Weltreich von Europa bis Amerika und Asien.",
        "facts_de": [
            "Philipp II. galt als Herrscher über ein globales Imperium.",
            "Spanische Kolonien lieferten enorme Reichtümer.",
            "Das Reich galt als „über dem die Sonne niemals untergeht“.",
        ],
        "period": "1580 CE",
        "tags": ["Spanien", "Kolonialreich"],
        "difficulty": "medium",
    },
    383: {
        "question_de": "In welchem Jahrhundert begannen die Napoleonischen Kriege in Europa?",
        "options_de": ["17. Jh.", "18. Jh.", "19. Jh.", "20. Jh."],
        "correct_de": "19. Jh.",
        "explanation_de": "Die Napoleonischen Kriege begannen im 19. Jahrhundert mit dem Aufstieg Napoleons Bonaparte.",
        "facts_de": [
            "Frankreich kämpfte gegen Koalitionen europäischer Mächte.",
            "Die Kriege veränderten Grenzen und Herrschaftsstrukturen.",
            "Napoleon errichtete kurzzeitig ein Großreich in Europa.",
        ],
        "period": "1803 CE",
        "tags": ["Napoleon", "Kriege"],
        "difficulty": "easy",
    },
    384: {
        "question_de": "Welcher französische Herrscher des 18. Jahrhunderts galt als „Philosophenkönig“ und unterstützte Ideen der Aufklärung?",
        "options_de": ["Ludwig XIV.", "Ludwig XV.", "Ludwig XVI.", "Heinrich IV."],
        "correct_de": "Ludwig XV.",
        "correct_ru": "Людовик XV",
        "explanation_de": "Ludwig XV. gilt als typischer „Philosophenkönig“ der Aufklärung: Er förderte Wissenschaft und Kultur am Hof, während Ludwig XVI. eher unter Reformdruck und Revolution stand.",
        "facts_de": [
            "Ludwig XV. regierte von 1715 bis 1774 und stützte Aufklärer wie Voltaire.",
            "Der Begriff „Philosophenkönig“ bezeichnet einen Herrscher, der Aufklärungsideen schützt.",
            "Ludwig XVI. wurde 1793 hingerichtet – das Ende der französischen Monarchie.",
        ],
        "period": "1770 CE",
        "tags": ["Frankreich", "Aufklärung"],
        "difficulty": "medium",
    },
    385: {
        "question_de": "Welcher Krieg von 1775–1783 in Nordamerika führte zur Unabhängigkeit der USA?",
        "options_de": [
            "Amerikanischer Unabhängigkeitskrieg",
            "Englische Revolution",
            "Französische Revolution",
            "Siebenjähriger Krieg",
        ],
        "correct_de": "Amerikanischer Unabhängigkeitskrieg",
        "explanation_de": "Der Amerikanische Unabhängigkeitskrieg führte zur Gründung der Vereinigten Staaten als souveräner Staat.",
        "facts_de": [
            "Der Konflikt wurde zwischen Kolonien und Großbritannien ausgetragen.",
            "1783 wurde die Unabhängigkeit der USA anerkannt.",
            "Der Krieg wurde zum Vorbild für Freiheitsbewegungen.",
        ],
        "period": "1779 CE",
        "tags": ["USA", "Unabhängigkeit"],
        "difficulty": "easy",
    },
    386: {
        "question_de": "Welche Macht schuf im 18. Jahrhundert ein großes Kolonialreich in Lateinamerika?",
        "options_de": ["Spanien", "Portugal", "England", "Frankreich"],
        "correct_de": "Spanien",
        "explanation_de": "Spanien beherrschte im 18. Jahrhundert große Teile Lateinamerikas als Kolonialreich.",
        "facts_de": [
            "Die Kolonien lieferten Gold und Silber nach Europa.",
            "Spanien kontrollierte Handel und Ressourcen.",
            "Das Reich gehörte zu den mächtigsten der Welt.",
        ],
        "period": "1750 CE",
        "tags": ["Spanien", "Lateinamerika"],
        "difficulty": "easy",
    },
    387: {
        "question_de": "In welchem Jahrhundert begann in Europa die Industrielle Revolution?",
        "options_de": ["17. Jh.", "18. Jh.", "19. Jh.", "20. Jh."],
        "correct_de": "18. Jh.",
        "explanation_de": "Die Industrielle Revolution begann im 18. Jahrhundert mit Maschinenbau und Fabrikproduktion.",
        "facts_de": [
            "Sie veränderte Wirtschaft und Gesellschaft grundlegend.",
            "Neue Technologien steigerten die Produktion stark.",
            "Die Revolution legte Grundlagen des modernen Kapitalismus.",
        ],
        "period": "1760 CE",
        "tags": ["Industrielle Revolution", "Wirtschaft"],
        "difficulty": "medium",
    },
    388: {
        "question_de": "Welche Macht gründete im 18. Jahrhundert die VOC und kontrollierte den Gewürzhandel in Asien?",
        "options_de": ["Spanien", "Portugal", "Niederlande", "Frankreich"],
        "correct_de": "Niederlande",
        "explanation_de": "Die Niederlande nutzten die VOC, um den asiatischen Gewürzhandel zu dominieren.",
        "facts_de": [
            "Die VOC war eine der ersten Aktiengesellschaften.",
            "Niederländische Kolonien lagen in Indien und Indonesien.",
            "Der Gewürzhandel brachte enorme Profite.",
        ],
        "period": "1750 CE",
        "tags": ["VOC", "Handel"],
        "difficulty": "medium",
    },
    389: {
        "question_de": "Welcher Krieg von 1803–1815 in Europa war mit Napoleons Kampf um die Hegemonie verbunden?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Napoleonische Kriege",
            "Siebenjähriger Krieg",
            "Österreichischer Erbfolgekrieg",
        ],
        "correct_de": "Napoleonische Kriege",
        "explanation_de": "Die Napoleonischen Kriege wurden zwischen Frankreich und europäischen Koalitionen um die Vorherrschaft geführt.",
        "facts_de": [
            "Sie führten zu neuen Grenzen und Staatenbildung.",
            "Napoleon errichtete kurzzeitig ein Großreich.",
            "Die Kriege veränderten die Weltpolitik nachhaltig.",
        ],
        "period": "1809 CE",
        "tags": ["Napoleon", "Kriege"],
        "difficulty": "medium",
    },
    390: {
        "question_de": "Welche Macht schuf im 18. Jahrhundert ein großes Kolonialreich in Afrika und Asien?",
        "options_de": ["Spanien", "Portugal", "England", "Frankreich"],
        "correct_de": "England",
        "explanation_de": "England baute im 18. Jahrhundert ein Kolonialreich in Afrika und Asien auf.",
        "facts_de": [
            "Die East India Company (EIC) kontrollierte den Handel in Indien.",
            "England gründete Kolonien in Afrika.",
            "Das Reich wurde zu einer der mächtigsten der Welt.",
        ],
        "period": "1750 CE",
        "tags": ["England", "Kolonialismus"],
        "difficulty": "medium",
    },
    391: {
        "question_de": "Welche Revolution von 1789 in Europa führte zum Sturz der Monarchie und zur Republik?",
        "options_de": [
            "Englische Revolution",
            "Glorreiche Revolution",
            "Französische Revolution",
            "Amerikanische Revolution",
        ],
        "correct_de": "Französische Revolution",
        "explanation_de": "Die Französische Revolution von 1789 stürzte die Monarchie und führte zur Ausrufung der Republik.",
        "facts_de": [
            "Die Revolution veränderte die politische Landkarte Europas.",
            "Ihre Ideen beeinflussten viele Länder.",
            "Sie wurde zum Symbol für Freiheit und Gleichheit.",
        ],
        "period": "1789 CE",
        "tags": ["Französische Revolution", "Republik"],
        "difficulty": "easy",
    },
    392: {
        "question_de": "Welche Macht schuf im 18. Jahrhundert ein Kolonialreich in Nordamerika und Indien?",
        "options_de": ["Spanien", "Portugal", "England", "Frankreich"],
        "correct_de": "England",
        "explanation_de": "England baute im 18. Jahrhundert Kolonien in Nordamerika und ein Imperium in Indien auf.",
        "facts_de": [
            "Die EIC kontrollierte den indischen Handel.",
            "Englische Kolonien entstanden an der amerikanischen Ostküste.",
            "Das Reich wurde zur führenden Kolonialmacht.",
        ],
        "period": "1750 CE",
        "tags": ["England", "Kolonialismus"],
        "difficulty": "medium",
    },
    393: {
        "question_de": "In welchem Jahrhundert begann in Europa die Epoche der Aufklärung?",
        "options_de": ["16. Jh.", "17. Jh.", "18. Jh.", "19. Jh."],
        "correct_de": "18. Jh.",
        "explanation_de": "Die Aufklärung begann im 18. Jahrhundert und verband Rationalismus, Wissenschaft und Kritik an traditioneller Autorität.",
        "facts_de": [
            "Aufklärer wie Voltaire und Kant prägten die Epoche.",
            "Bildung und Wissenschaft gewannen an Bedeutung.",
            "Aufklärungsideen beeinflussten die Französische Revolution.",
        ],
        "period": "1750 CE",
        "tags": ["Aufklärung", "Philosophie"],
        "difficulty": "easy",
    },
    394: {
        "question_de": "Welcher Krieg von 1756–1763 wurde in Europa zum globalen Konflikt zwischen den Großmächten?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Siebenjähriger Krieg",
            "Spanischer Erbfolgekrieg",
            "Napoleonische Kriege",
        ],
        "correct_de": "Siebenjähriger Krieg",
        "explanation_de": "Der Siebenjährige Krieg wurde zwischen europäischen Mächten ausgetragen und erstreckte sich auch auf Amerika und Asien.",
        "facts_de": [
            "Der Krieg führte zur Neuverteilung von Kolonien.",
            "England gewann bedeutende Gebiete in Nordamerika.",
            "Er gilt als erster „Weltkrieg“ der Neuzeit.",
        ],
        "period": "1759 CE",
        "tags": ["Siebenjähriger Krieg", "Kriege"],
        "difficulty": "medium",
    },
    395: {
        "question_de": "Welche Macht wurde im 18. Jahrhundert zum Hauptrivalen Englands in Kolonialhandel und Kriegen?",
        "options_de": ["Spanien", "Portugal", "Frankreich", "Niederlande"],
        "correct_de": "Frankreich",
        "explanation_de": "Frankreich wurde im 18. Jahrhundert zum wichtigsten Rivalen Englands in Kolonialhandel und Seekriegen.",
        "facts_de": [
            "Beide Mächte kämpften um Kolonien in Amerika und Asien.",
            "Frankreich verlor viele Kolonien in den Kriegen.",
            "Die Rivalität prägte die europäische Politik des Jahrhunderts.",
        ],
        "period": "1750 CE",
        "tags": ["Frankreich", "England"],
        "difficulty": "medium",
    },
    396: {
        "question_de": "Welche Revolution von 1688 in England beschränkte die Königsmacht und stärkte das Parlament?",
        "options_de": [
            "Englische Revolution",
            "Glorreiche Revolution",
            "Französische Revolution",
            "Amerikanische Revolution",
        ],
        "correct_de": "Glorreiche Revolution",
        "explanation_de": "Die Glorreiche Revolution von 1688 machte die englische Monarchie konstitutionell und stärkte das Parlament.",
        "facts_de": [
            "Die Monarchie wurde nicht absolut, sondern verfassungsgebunden.",
            "Wilhelm von Oranien und Maria II. übernahmen die Krone.",
            "Die Revolution legte Grundlagen der modernen Demokratie.",
        ],
        "period": "1688 CE",
        "tags": ["England", "Parlament"],
        "difficulty": "medium",
    },
    397: {
        "question_de": "Welche Macht gründete im 17. Jahrhundert die East India Company (EIC) und kontrollierte den Handel in Indien?",
        "options_de": ["Spanien", "Portugal", "England", "Frankreich"],
        "correct_de": "England",
        "explanation_de": "England gründete die East India Company, die den Handel in Indien dominierte.",
        "facts_de": [
            "Die EIC wurde zur Basis des britischen Kolonialreichs.",
            "Sie kontrollierte Gewürze, Textilien und Rohstoffe.",
            "Die Kompanie übte politische Macht in Indien aus.",
        ],
        "period": "1650 CE",
        "tags": ["England", "Indien"],
        "difficulty": "medium",
    },
    398: {
        "question_de": "In welchem Jahrhundert begann in Europa die Epoche des Kolonialismus?",
        "options_de": ["15. Jh.", "16. Jh.", "10. Jh.", "17. Jh."],
        "correct_de": "15. Jh.",
        "explanation_de": "Der europäische Kolonialismus begann im 15. Jahrhundert mit neuen Seewege und Kolonien.",
        "facts_de": [
            "Portugal und Spanien kolonisierten Afrika und Amerika.",
            "Kolonialismus veränderte Ressourcen- und Bevölkerungsströme.",
            "Die Kolonisierung veränderte die Weltwirtschaft nachhaltig.",
        ],
        "period": "1475 CE",
        "tags": ["Kolonialismus", "Epochen"],
        "difficulty": "easy",
    },
    399: {
        "question_de": "Welche Macht kontrollierte im 16.–17. Jahrhundert riesige Gebiete in Europa und Asien und galt als Reich, „über dem die Sonne niemals untergeht“?",
        "options_de": ["Spanien", "Portugal", "Frankreich", "England"],
        "correct_de": "Spanien",
        "explanation_de": "Spanien beherrschte im 16. und 17. Jahrhundert ein Weltreich von Europa bis Amerika und Asien.",
        "facts_de": [
            "Philipp II. galt als Herrscher über ein globales Imperium.",
            "Spanische Kolonien lieferten enorme Reichtümer.",
            "Das Reich erstreckte sich über mehrere Kontinente.",
        ],
        "period": "1650 CE",
        "tags": ["Spanien", "Kolonialreich"],
        "difficulty": "medium",
    },
    400: {
        "question_de": "Welcher Krieg von 1740–1748 in Europa drehte sich um die österreichische Thronfolge?",
        "options_de": [
            "Dreißigjähriger Krieg",
            "Österreichischer Erbfolgekrieg",
            "Siebenjähriger Krieg",
            "Spanischer Erbfolgekrieg",
        ],
        "correct_de": "Österreichischer Erbfolgekrieg",
        "explanation_de": "Der Österreichische Erbfolgekrieg wurde zwischen europäischen Mächten um Einfluss auf Österreich geführt.",
        "facts_de": [
            "Der Konflikt veränderte Machtverhältnisse in Europa.",
            "Österreich konnte seine Position teilweise sichern.",
            "Der Krieg war Teil der Rivalität um die Hegemonie.",
        ],
        "period": "1744 CE",
        "tags": ["Österreich", "Kriege"],
        "difficulty": "hard",
    },
}


def _ru_facts(ru: dict, de: dict) -> list[str]:
    if "facts_ru" in de:
        return de["facts_ru"]
    merged = _merge_ru_explanation(ru)
    parts = [p.strip() for p in re.split(r"(?<=[.!?])\s+", merged) if len(p.strip()) > 12]
    if len(parts) >= 3:
        return parts[:3]
    raw = [f.strip().strip('"') for f in ru.get("facts", []) if f.strip()]
    if len(raw) >= 3:
        return raw[:3]
    while len(parts) < 3:
        parts.append(merged)
    return parts[:3]


def build_question(ru: dict, de: dict, qid: int) -> dict:
    options_ru = ru["options"]
    correct_ru = de.get("correct_ru", ru["correct"])
    options_de = de["options_de"]
    correct_de = de["correct_de"]

    correct_idx_ru = options_ru.index(correct_ru)
    correct_idx_de = options_de.index(correct_de)

    wrong_idx_de = [i for i in range(4) if i != correct_idx_de]
    wrong_idx_ru = [i for i in range(4) if i != correct_idx_ru]

    facts_ru = _ru_facts(ru, de)
    facts_de = de["facts_de"]

    return {
        "id": qid,
        "question_de": de["question_de"],
        "question_ru": ru["question"],
        "correct_answer_de": correct_de,
        "correct_answer_ru": correct_ru,
        "wrong_answers_de": [options_de[i] for i in wrong_idx_de[:3]],
        "wrong_answers_ru": [options_ru[i] for i in wrong_idx_ru[:3]],
        "explanation_de": de["explanation_de"],
        "explanation_ru": _merge_ru_explanation(ru),
        "difficulty": de["difficulty"],
        "category": "Frühe Neuzeit",
        "type": "factual",
        "period": de["period"],
        "tags": de["tags"],
        "interesting_facts": [
            {"de": facts_de[i], "ru": facts_ru[i]}
            for i in range(3)
        ],
    }


def _merge_ru_explanation(ru: dict) -> str:
    parts = [ru.get("explanation", "").strip()]
    for f in ru.get("facts", []):
        t = f.strip().strip('"')
        if t and t not in parts[0]:
            parts.append(t)
    text = " ".join(p for p in parts if p)
    return text.replace("  ", " ").strip()


def main() -> None:
    ru_items = json.loads(RU_PATH.read_text(encoding="utf-8"))
    out: list[dict] = []
    qid = 7001
    missing = []

    for ru in sorted(ru_items, key=lambda x: x["source_id"]):
        sid = ru["source_id"]
        if sid not in DE:
            missing.append(sid)
            continue
        out.append(build_question(ru, DE[sid], qid))
        qid += 1

    if missing:
        raise SystemExit(f"Missing DE translations for source_ids: {missing}")

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(out)} questions to {OUT_PATH}")


if __name__ == "__main__":
    main()
