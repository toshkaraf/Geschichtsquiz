# -*- coding: utf-8 -*-
"""Glossary terms for auto-generated medieval concept questions."""

from __future__ import annotations


def rich_facts_for_term(
    term_de: str,
    term_ru: str,
    year: int,
    ans_de: str,
    ans_ru: str,
    tag_de: str,
    tag_ru: str,
) -> list[dict[str, str]]:
    century = year // 100 + 1
    return [
        {
            "de": (
                f"«{term_de}» ({tag_de}, etwa {year}): {ans_de}. "
                f"In Urkunden, Chroniken und Rechtsquellen belegt der Begriff konkrete "
                f"Macht- und Alltagspraxis – nicht nur abstrakte Theorie."
            ),
            "ru": (
                f"«{term_ru}» («{tag_ru}», около {year}): {ans_ru}. "
                f"В грамотах, хрониках и правовых источниках термин фиксирует "
                f"конкретную властную и бытовую практику, а не одну лишь абстракцию."
            ),
        },
        {
            "de": (
                f"Im {century}. Jahrhundert tauchte «{term_de}» in Lehenbriefen, "
                f"Stadtregistern und kirchlichen Akten auf – oft mit leicht "
                f"unterschiedlicher Bedeutung je nach Region und Stand."
            ),
            "ru": (
                f"В {century}-м веке «{term_ru}» встречалось в ленных грамотах, "
                f"городских реестрах и церковных актах — с разными оттенками "
                f"в зависимости от региона и сословия."
            ),
        },
        {
            "de": (
                f"Für die {tag_de}-Forschung ist «{term_de}» eine Leitkategorie: "
                f"Sie hilft zu erklären, wie Menschen im Mittelalter Ordnung, "
                f"Autorität und Konflikt verstanden – und was sich bis zum 15. Jahrhundert wandelte."
            ),
            "ru": (
                f"Для изучения «{tag_ru}» «{term_ru}» — важная категория: "
                f"через неё видно, как в Средневековье понимали порядок, власть и конфликт — "
                f"и что изменилось к XV веку."
            ),
        },
    ]


def build_auto_concepts() -> list[dict]:
    terms: list[tuple[str, str, int, str, str, str, str]] = [
        ("Lehen", "лен", 1050, "Vasallentreue gegen Nutzungsrecht", "вассальная верность против права пользования", "Feudalismus", "феодализм"),
        ("Vasall", "вассал", 1100, "Untergeordneter des Lehnsherrn", "подчинённый сеньора", "Feudalismus", "феодализм"),
        ("Homagium", "оммаж", 1100, "Lehnseid des Vasallen", "вассальная присяга", "Feudalismus", "феодализм"),
        ("Minnesang", "миннезанг", 1200, "Höfische Liebeslyrik", "придворная любовная лирика", "Kultur", "культура"),
        ("Nibelungenlied", "«Песнь о Нибелунгах»", 1200, "Deutsches Heldenepos", "немецкий героический эпос", "Literatur", "литература"),
        ("Kathedrale", "собор", 1200, "Große Bischofskirche", "крупная епископальная церковь", "Architektur", "архитектура"),
        ("Romanik", "романский стиль", 1100, "Rundbogenstil der Kirchen", "стиль с полукруглыми арками", "Architektur", "архитектура"),
        ("Gotik", "готика", 1250, "Spitzbogenarchitektur", "стрельчатая архитектура", "Architektur", "архитектура"),
        ("Universitas", "университет", 1150, "Gelehrte Gemeinschaft mit Studienprivilegien", "учёное сообщество с привилегиями", "Bildung", "образование"),
        ("Hanse", "Ганза", 1356, "Städtebund für Nord- und Ostseehandel", "союз городов Северной и Балтийской торговли", "Handel", "торговля"),
        ("Zunft", "цех", 1300, "Städtische Berufs- und Regelgemeinschaft", "городское объединение мастеров", "Städte", "города"),
        ("Gilde", "гильдия", 1250, "Genossenschaft von Kaufleuten oder Handwerkern", "объединение купцов или ремесленников", "Städte", "города"),
        ("Inquisition", "инквизиция", 1230, "Kirchengericht gegen Häresie", "церковный суд против ереси", "Kirche", "церковь"),
        ("Kreuzzug", "крестовый поход", 1095, "Vom Papst gebilligter Kriegszug", "одобренный папой поход", "Kreuzzüge", "крестовые походы"),
        ("Reconquista", "Реконкиста", 1492, "Rückeroberung der Iberischen Halbinsel", "отвоевание Пиреней", "Spanien", "Испания"),
        ("Schisma von 1054", "схизма 1054 года", 1054, "Trennung von Ost- und Westkirche", "разделение церквей", "Kirche", "церковь"),
        ("Mendikantenorden", "нищенствующий орден", 1210, "Bettelorden in der Stadt", "городской нищенствующий орден", "Ordenswesen", "монашество"),
        ("Ritterorden", "рыцарский орден", 1120, "Geistlich-ritterliche Gemeinschaft", "духовно-рыцарское объединение", "Ordenswesen", "монашество"),
        ("Wikinger", "викинг", 850, "Seefahrer und Krieger aus Skandinavien", "мореплаватели Скандинавии", "Wikinger", "викинги"),
        ("Varjage", "варяги", 900, "Nordische Krieger in der Rus", "скандинавские воины на Руси", "Russland", "Русь"),
        ("Veche", "вече", 1100, "Volksversammlung in Nowgorod", "народное собрание в Новгороде", "Russland", "Русь"),
        ("Goldene Horde", "Золотая Орда", 1240, "Mongolischer Überstaat in Osteuropa", "монгольское господство", "Mongolen", "монголы"),
        ("Ikonoklasmus", "иконоборчество", 730, "Bilderstreit in Byzanz", "борьба с иконами", "Byzanz", "Византия"),
        ("Thema", "фема", 700, "Byzantinische Militärprovinz", "византийская военная область", "Byzanz", "Византия"),
        ("Janitschar", "яничар", 1360, "Elite-Infanterie des Sultans", "элитная пехота султана", "Osmanen", "османы"),
        ("Condottiere", "кондотьер", 1400, "Söldnerführer in Italien", "глава наёмников", "Italien", "Италия"),
        ("Langbogen", "длинный лук", 1346, "Englische Waffe großer Reichweite", "английский длинный лук", "Militär", "военное дело"),
        ("Belagerung", "осада", 1200, "Einschließung einer Festung", "блокада крепости", "Militär", "военное дело"),
        ("Turnier", "рыцарский турнир", 1200, "Ritterlicher Wettkampf", "рыцарское состязание", "Militär", "военное дело"),
        ("Kurfürst", "курфюрст", 1356, "Wähler des deutschen Königs", "выборщик короля", "Reich", "империя"),
        ("Reichstag", "рейхстаг", 1495, "Versammlung der Reichsstände", "собрание сословий империи", "Reich", "империя"),
        ("Landfriede", "земский мир", 1103, "Schutz des Reisens und Handels", "охрана путей и торговли", "Reich", "империя"),
        ("Stadtrecht", "городское право", 1200, "Rechtsordnung einer Stadt", "правовой устав города", "Städte", "города"),
        ("Zehnt", "десятина", 1000, "Kirchenabgabe von Erträgen", "церковная десятая", "Kirche", "церковь"),
        ("Wallfahrt", "паломничество", 1100, "Reise zu heiligen Stätten", "путешествие к святыням", "Religion", "религия"),
        ("Indulgenz", "индульгенция", 1200, "Nachlass von Kirchenstrafen", "освобождение от церковных наказаний", "Kirche", "церковь"),
        ("Reliquie", "мощи", 1100, "Überreste Heiliger als Kultobjekte", "останки святых", "Religion", "религия"),
        ("Scholastik", "схоластика", 1250, "Systematische Verbindung von Glaube und Vernunft", "систематическое богословие", "Scholastik", "схоластика"),
        ("Mystik", "мистика", 1300, "Unmittelbare Gotteserfahrung", "непосредственный опыт Бога", "Religion", "религия"),
        ("Skriptorium", "скрипторий", 900, "Schreibraum des Klosters", "монастырская скриптория", "Kultur", "культура"),
        ("Trivium", "тривиум", 800, "Grammatik, Rhetorik, Dialektik", "грамматика, риторика, диалектика", "Bildung", "образование"),
        ("Quadrivium", "квадривиум", 900, "Vier mathematische Künste", "четыре математических искусства", "Bildung", "образование"),
        ("Karawane", "караван", 1100, "Geleitschutz auf Handelsrouten", "торговый обоз", "Handel", "торговля"),
        ("Seidenstraße", "Шёлковый путь", 1100, "Fernhandelsroute nach Asien", "путь в Азию", "Handel", "торговля"),
        ("Flagellanten", "флагелланты", 1349, "Bußbewegung während der Pest", "самобичевание во время чумы", "Seuche", "чума"),
        ("Bauernaufstand", "крестьянское восстание", 1381, "Sozialer Protest der Unterschichten", "социальный протест низов", "Gesellschaft", "общество"),
        ("Jacquerie", "жакерия", 1358, "Bauernaufstand in Frankreich", "крестьянское восстание во Франции", "Frankreich", "Франция"),
        ("Avignonexil", "авиньонское пленение", 1309, "Papstsitz in Avignon", "папство в Авиньоне", "Kirche", "церковь"),
        ("Konklave", "конклав", 1274, "Geheimwahl des Papstes", "тайное избрание папы", "Kirche", "церковь"),
        ("Commenda", "комменда", 1100, "Verwaltung fremden Klosterbesitzes", "управление чужим монастырским имуществом", "Ordenswesen", "монашество"),
        ("Commune", "коммуна", 1100, "Städtische Selbstverwaltung", "городское самоуправление", "Städte", "города"),
        ("Bergrecht", "горное право", 1200, "Rechte beim Bergbau", "право на добычу руды", "Wirtschaft", "экономика"),
        ("Münzregal", "монетный суверенитет", 1100, "Herrschaftliches Münzrecht", "право чеканки монет", "Wirtschaft", "экономика"),
        ("Leibeigenschaft", "крепостное право", 1400, "Rechtliche Bindung der Bauern", "зависимость крестьян", "Gesellschaft", "общество"),
        ("Hörigkeit", "подчинённость", 1200, "Abhängigkeit von Grundherrn", "зависимость от сеньора", "Gesellschaft", "общество"),
        ("Burgfrieden", "замковый мир", 1100, "Schutzzone um die Burg", "мир вокруг замка", "Recht", "право"),
        ("Blutfehde", "кровная месть", 1100, "Private Vergeltung im Adelsrecht", "личная месть в праве знати", "Recht", "право"),
        ("Ordeal", "ордалия", 1000, "Gottesurteil im Recht", "судебное божье испытание", "Recht", "право"),
        ("Ketzergericht", "суд над еретиками", 1200, "Verfahren gegen Abweichler", "процесс против еретиков", "Kirche", "церковь"),
        ("Albigenser", "альбигойцы", 1209, "Ketzerbewegung im Languedoc", "еретическое движение в Лангедоке", "Häresie", "ересь"),
        ("Waldenser", "вальденсы", 1170, "Bewegung der armen Frommen", "движение «бедных во Христе»", "Häresie", "ересь"),
        ("Dominikaner", "доминиканцы", 1216, "Orden der Prediger", "орден проповедников", "Ordenswesen", "монашество"),
        ("Franziskaner", "францисканцы", 1209, "Orden der Minderbrüder", "орден меньших братьев", "Ordenswesen", "монашество"),
        ("Templer", "тамплиеры", 1120, "Orden zum Schutz der Pilger", "орден защиты паломников", "Kreuzzüge", "крестовые походы"),
        ("Johanniter", "иоанниты", 1113, "Ordenshospitaliter", "госпитальеры", "Kreuzzüge", "крестовые походы"),
        ("Deutscher Orden", "тевтонский орден", 1190, "Ritterorden im Baltikum", "орден на Балтике", "Ordenswesen", "монашество"),
        ("Kreuzfahrerstaat", "крестоносное государство", 1099, "Lateinisches Königreich Jerusalem", "латинское королевство", "Kreuzzüge", "крестовые походы"),
        ("Konstanzer Konzil", "Констанцский собор", 1414, "Kirchenversammlung zur Schismabekämpfung", "собор против схизмы", "Kirche", "церковь"),
        ("Laterankonzil IV.", "IV Латеранский собор", 1215, "Wichtiges Papstkonzil", "важный собор папы", "Kirche", "церковь"),
        ("Wormser Konkordat", "Вормсский конкордат", 1122, "Ausgleich im Investiturstreit", "компромисс в инвеститурной схватке", "Reich", "империя"),
        ("Goldene Bulle", "Золотая булла", 1356, "Reichsgesetz zur Kaiserwahl", "закон о выборах императора", "Reich", "империя"),
        ("Magna Carta", "Магна Карта", 1215, "Charte der englischen Barone", "хартия английских баронов", "England", "Англия"),
        ("Hundertjähriger Krieg", "Столетняя война", 1337, "Langzeitkonflikt England–Frankreich", "долгая война Англии и Франции", "Krieg", "война"),
        ("Schwarzer Tod", "Чёрная смерть", 1347, "Pestpandemie in Europa", "чумная пandemия", "Seuche", "чума"),
        ("Peasants' Revolt", "восстание Уота Тайлера", 1381, "Bauernaufstand in England", "английское крестьянское восстание", "England", "Англия"),
        ("Städtebund", "городской союз", 1300, "Zusammenschluss für Selbstschutz", "союз для самозащиты", "Städte", "города"),
        ("Flandern", "Фландрия", 1302, "Reiche Tuchmanufaktur", "центр суконного производства", "Wirtschaft", "экономика"),
        ("Hansekontor", "ганзейская контора", 1350, "Handelsniederlassung der Hanse", "торговая контора Ганзы", "Handel", "торговля"),
        ("Nowgorod", "Новгород", 1136, "Handelsrepublik im Norden", "торговая республика на севере", "Russland", "Русь"),
        ("Kiew", "Киев", 988, "Frühes Zentrum der Rus", "ранний центр Руси", "Russland", "Русь"),
        ("Moskau", "Москва", 1328, "Aufstieg als politisches Zentrum", "политический подъём Москвы", "Russland", "Русь"),
        ("Kulikowo", "Куликово", 1380, "Schlacht gegen die Goldene Horde", "битва с Ордой", "Russland", "Русь"),
        ("Peipussee", "Чудское озеро", 1242, "Schlacht der Russen gegen die Livländischen Ritter", "Ледовое побоище", "Russland", "Русь"),
        ("Bagdad", "Багдад", 1258, "Zerstörung durch die Mongolen", "разрушение монголами", "Islam", "ислам"),
        ("Kalifat", "халифат", 750, "Islamisches Großreich", "исламская империя", "Islam", "ислам"),
        ("Seldschuken", "сельджуки", 1071, "Türkische Dynastie in Kleinasien", "тюркская династия", "Islam", "ислам"),
        ("Mamluken", "мамлюки", 1250, "Sklavensoldaten-Herrschaft in Ägypten", "власть рабов-воинов", "Islam", "ислам"),
        ("Osmanisches Reich", "Османская империя", 1299, "Staat der Osmanendynastie", "государство османов", "Osmanen", "османы"),
        ("Fall Konstantinopels", "падение Константинополя", 1453, "Ende des Byzantinischen Reiches", "конец Византии", "Byzanz", "Византия"),
        ("Palaiologen", "Палеологи", 1261, "Letzte byzantinische Dynastie", "последняя византийская династия", "Byzanz", "Византия"),
        ("Komnenen", "Комнины", 1081, "Dynastie der byzantinischen Reform", "династия византийских реформ", "Byzanz", "Византия"),
        ("Basileus", "василевс", 900, "Titel des byzantinischen Kaisers", "титул византийского императора", "Byzanz", "Византия"),
        ("Griechisches Feuer", "греческий огонь", 670, "Brandwaffe der byzantinischen Flotte", "зажигательное оружие", "Byzanz", "Византия"),
        ("Normannen", "норманны", 911, "Skandinavische Siedler in der Normandie", "скандинавские поселенцы", "Normannen", "норманны"),
        ("Danelag", "Денло", 886, "Dänisches Recht in England", "данская зона в Англии", "England", "Англия"),
        ("Thing", "тинг", 900, "Versammlung der Freien", "собрание свободных", "Wikinger", "викинги"),
        ("Drakkar", "драккар", 900, "Wikinger-Langschiff", "корабль викингов", "Wikinger", "викинги"),
        ("Jarltum", "ярлство", 950, "Herrscherstand in Skandinavien", "власть ярла", "Wikinger", "викинги"),
        ("Karolingische Renaissance", "каролингское возрождение", 800, "Bildungsbewegung am Hof Karls des Großen", "образовательное движение", "Frankenreich", "Франки"),
        ("Vertrag von Verdun", "Верденский договор", 843, "Teilung des Frankenreichs", "раздел Франкского государства", "Frankenreich", "Франки"),
        ("Heiliges Römisches Reich", "Священная Римская империя", 962, "Mittelalterliches Kaisertum in Mitteleuropa", "средневековая империя", "Reich", "империя"),
        ("Staufer", "штауфены", 1138, "Deutsche Kaiserdynastie", "немецкая императорская династия", "Reich", "империя"),
        ("Welfen", "вельфы", 1150, "Rivale der Staufer", "соперники штауфенов", "Reich", "империя"),
        ("Investiturstreit", "инвеститурная схватка", 1076, "Konflikt um Bischofseinsetzung", "спор о инвеституре", "Kirche", "церковь"),
        ("Canossa", "Каносса", 1077, "Buße Heinrichs IV. vor dem Papst", "покаяние Генриха IV", "Investiturstreit", "инвеститурная схватка"),
        ("Buchdruck", "книгопечатание", 1450, "Massenhafte Vervielfältigung von Texten", "массовое тиражирование текстов", "Kultur", "культура"),
        ("Humanismus", "гуманизм", 1400, "Rückbesinnung auf antike Texte", "обращение к античности", "Renaissance", "Ренессанс"),
        ("Renaissance", "Ренессанс", 1400, "Kulturelle Erneuerung in Italien", "культурное обновление", "Italien", "Италия"),
        ("Medici", "Медичи", 1434, "Florentinische Bankiersfamilie", "флорентийский банкирский род", "Italien", "Италия"),
        ("Signoria", "синьория", 1300, "Städtische Herrschaft in Italien", "городская власть в Италии", "Italien", "Италия"),
        ("Doge", "дож", 697, "Oberhaupt Venedigs", "глава Венеции", "Italien", "Италия"),
        ("Marco Polo", "Марко Поло", 1271, "Reisebericht aus China", "путешествие в Китай", "Handel", "торговля"),
        ("Schiffe der Hanse", "ганзейские когги", 1300, "Handelsschiffe der Nordsee", "торговые суда", "Handel", "торговля"),
        ("Bergbau", "горное дело", 1200, "Gewinnung von Erz in Mitteleuropa", "добыча руды", "Wirtschaft", "экономика"),
        ("Salz", "соль", 1200, "Wichtiges mittelalterliches Handelsgut", "важный товар торговли", "Wirtschaft", "экономика"),
        ("Wolle", "шерсть", 1300, "Hauptexport Englands", "главный экспорт Англии", "Wirtschaft", "экономика"),
        ("Wein", "вино", 1200, "Handels- und Kulturgut", "торговый и культурный товар", "Wirtschaft", "экономика"),
        ("Backstein gotik", "кирпичная готика", 1300, "Backsteinbau in Norddeutschland", "кирпичное зодчество", "Architektur", "архитектура"),
        ("Burgturm", "донжон", 1100, "Zentraler Wehrturm", "главная башня замка", "Architektur", "архитектура"),
        ("Zisterzienser", "цистерцианцы", 1098, "Strenge Klosterreform", "строгая реформа", "Ordenswesen", "монашество"),
        ("Cluniazenser", "клюнийцы", 910, "Klosterreform von Cluny", "клюнийская реформа", "Ordenswesen", "монашество"),
        ("Benediktinerregel", "бенедиктинский устав", 530, "Regel für Klostergemeinschaften", "устав монашества", "Ordenswesen", "монашество"),
        ("Kreuzzugsplakette", "крестоносный крест", 1099, "Symbol des Kreuzfahrers", "символ крестоносца", "Kreuzzüge", "крестовые походы"),
        ("Konrad von Montferrat", "Конрад Монферратский", 1192, "König von Jerusalem", "король Иерусалима", "Kreuzzüge", "крестовые походы"),
        ("Dschingis Khan", "Чингисхан", 1206, "Vereinigung der Mongolen", "объединение монголов", "Mongolen", "монголы"),
        ("Kublai Khan", "Хубилай", 1271, "Yuan-Dynastie in China", "династия Юань", "Mongolen", "монголы"),
        ("Hulagu", "Хулагу", 1258, "Zerstörung Bagdads", "разрушение Багдада", "Mongolen", "монголы"),
        ("Stamford Bridge", "Стамфорд-Бридж", 1066, "Schlacht gegen Harald Hardrada", "битва с Харальдом", "England", "Англия"),
        ("Bannockburn", "Бэннокберн", 1314, "Schottischer Sieg über England", "победа Шотландии", "Schottland", "Шотландия"),
        ("Azincourt", "Азенкур", 1415, "Englischer Sieg im Hundertjährigen Krieg", "английская победа", "Hundertjähriger Krieg", "Столетняя война"),
        ("Bouvines", "Бувин", 1214, "Französischer Sieg über die Allianz", "французская победа", "Frankreich", "Франция"),
        ("Manzikert", "Манцикерт", 1071, "Seldschukischer Sieg über Byzanz", "победа сельджуков", "Byzanz", "Византия"),
        ("Ankara", "Анкара", 1402, "Timurs Sieg über die Osmanen", "победа Тамерлана", "Osmanen", "османы"),
        ("Varna", "Варна", 1444, "Osmanischer Sieg im Balkan", "османская победа", "Osmanen", "османы"),
        ("Grunwald", "Грюнвальд", 1410, "Sieg von Polen-Litauen", "победа Польши и Литвы", "Polen", "Польша"),
        ("Nikäa", "Никея", 787, "Konzil zur Ikonenfrage", "собор об иконах", "Byzanz", "Византия"),
        ("Clermont", "Клермон", 1095, "Kreuzzugsaufruf Urbans II.", "призыв Урбана II", "Kreuzzüge", "крестовые походы"),
        ("Runnymede", "Раннимид", 1215, "Ort der Magna Carta", "место Магны Карты", "England", "Англия"),
        ("Aachen", "Ахен", 800, "Krönungsstadt Karls des Großen", "коронационный город Карла", "Frankenreich", "Франки"),
        ("Avignon", "Авиньон", 1309, "Papstsitz im Exil", "резиденция пап", "Kirche", "церковь"),
        ("Lübeck", "Любек", 1226, "Hauptstadt der Hanse", "главный город Ганзы", "Handel", "торговля"),
        ("Brügge", "Брюгге", 1300, "Hansekontor in Flandern", "ганзейская контора", "Handel", "торговля"),
        ("Novgorodski Handel", "новгородская торговля", 1200, "Pelzhandel mit dem Norden", "пушнина с севера", "Handel", "торговля"),
    ]
    out: list[dict] = []
    all_ans_de = [t[3] for t in terms]
    all_ans_ru = [t[4] for t in terms]
    for term_de, term_ru, year, ans_de, ans_ru, tag_de, tag_ru in terms:
        pool_de = [a for a in all_ans_de if a != ans_de]
        pool_ru = [a for a in all_ans_ru if a != ans_ru]
        wrong_de = (pool_de[:3] if len(pool_de) >= 3 else pool_de + ["Nur Neuzeit", "Nur Antike", "Nur Industrie"])[:3]
        wrong_ru = (pool_ru[:3] if len(pool_ru) >= 3 else pool_ru + ["Только Новое время", "Только античность", "Только индустрия"])[:3]
        expl_de_1 = (
            f"«{term_de}» bezeichnet im Mittelalter: {ans_de}. "
            f"Der Begriff ist ein zentrales Konzept des Themenfelds {tag_de} und taucht besonders "
            f"ab dem {year // 100 + 1}. Jahrhundert in Quellen auf."
        )
        expl_ru_1 = (
            f"«{term_ru}» — средневековый термин, означающий: {ans_ru}. "
            f"Это ключевое понятие темы «{tag_ru}», особенно активно встречается в источниках "
            f"начиная с {year} года."
        )
        expl_de_2 = (
            f"Der Fachbegriff «{term_de}» steht für: {ans_de}. "
            f"Im Kontext des mittelalterlichen {tag_de} ist er unentbehrlich, "
            f"um politische, religiöse oder soziale Prozesse zu verstehen."
        )
        expl_ru_2 = (
            f"Термин «{term_ru}» обозначает: {ans_ru}. "
            f"В контексте средневековой темы «{tag_ru}» без него невозможно понять "
            f"политические, религиозные или социальные процессы."
        )
        base_facts = rich_facts_for_term(
            term_de, term_ru, year, ans_de, ans_ru, tag_de, tag_ru
        )
        out.append({
            "q_de": f"Was bezeichnet der mittelalterliche Begriff «{term_de}»?",
            "q_ru": f"Что обозначает средневековый термин «{term_ru}»?",
            "ans_de": ans_de, "ans_ru": ans_ru,
            "wrong_de": wrong_de, "wrong_ru": wrong_ru,
            "expl_de": expl_de_1,
            "expl_ru": expl_ru_1,
            "year": year, "type": "definition", "difficulty": "medium",
            "tags": [tag_de, "Begriff"], "facts": base_facts,
        })
        out.append({
            "q_de": f"Welche Erklärung passt zu «{term_de}»?",
            "q_ru": f"Какое объяснение подходит к «{term_ru}»?",
            "ans_de": ans_de, "ans_ru": ans_ru,
            "wrong_de": wrong_de[::-1], "wrong_ru": wrong_ru[::-1],
            "expl_de": expl_de_2,
            "expl_ru": expl_ru_2,
            "year": year, "type": "definition", "difficulty": "easy",
            "tags": [tag_de, "Begriff"], "facts": base_facts,
        })
    return out
