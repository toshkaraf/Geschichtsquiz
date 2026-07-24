#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build entity list from compact seeds + hand-tuned batch1."""
from medieval_entity_helper import e

# name_de, name_ru, year, cat_de, cat_ru, event_de, event_ru, place_de, place_ru
RAW_SEEDS: list[tuple] = [
    ("Heinrich IV.", "Генрих IV", 1077, "Investiturstreit", "Инвеститурная схватка", "der Gang nach Canossa", "поход в Каноссу", "Canossa", "Каносса"),
    ("Gregor VII.", "Григорий VII", 1077, "Investiturstreit", "Инвеститурная схватка", "die Buße Heinrichs IV.", "покаяние Генриха IV", "Canossa", "Каносса"),
    ("Friedrich II.", "Фридрих II", 1220, "Staufer", "Штауфены", "die Krönung in Jerusalem", "коронация в Иерусалиме", "Jerusalem", "Иерусалим"),
    ("Innozenz III.", "Иннокентий III", 1215, "Kirche", "Церковь", "das Vierte Laterankonzil", "IV Латеранский собор", "Rom", "Рим"),
    ("Thomas von Aquin", "Фома Аквинский", 1274, "Scholastik", "Схоластика", "die Summa theologiae", "«Сумма теологии»", "Paris", "Париж"),
    ("Franz von Assisi", "Франциск Ассизский", 1224, "Ordenswesen", "Монашество", "die Gründung des Franziskanerordens", "основание ордена францисканцев", "Assisi", "Ассизи"),
    ("Isabella I. von Kastilien", "Изабелла I", 1492, "Spanien", "Испания", "die Eroberung Granadas", "завоевание Гранады", "Granada", "Гранада"),
    ("Ferdinand II. von Aragón", "Фердинанд Арагонский", 1492, "Spanien", "Испания", "die Vereinigung der Kronen", "объединение корон", "Granada", "Гранада"),
    ("Iwan III. Wassiljewitsch", "Иван III", 1480, "Russland", "Русь", "das Ende der Ordnungsherrschaft", "конец ордынского ига", "Moskau", "Москва"),
    ("Jan Hus", "Ян Гус", 1415, "Hussitismus", "Гуситство", "die Verurteilung in Konstanz", "осуждение в Констанце", "Konstanz", "Констанц"),
    ("Władysław II. Jagiełło", "Ягайло", 1410, "Polen-Litauen", "Польша-Литва", "die Schlacht bei Grunwald", "битва при Грюнвальде", "Grunwald", "Грюнвальд"),
    ("Timur", "Тамерлан", 1402, "Zentralasien", "Центральная Азия", "die Schlacht von Ankara", "битва при Анкаре", "Ankara", "Анкара"),
    ("Mehmed II.", "Мехмед II", 1453, "Osmanen", "Османы", "die Eroberung Konstantinopels", "падение Константинополя", "Konstantinopel", "Константинополь"),
    ("Johannes Gutenberg", "Иоганн Гутенберг", 1450, "Kultur", "Культура", "den Buchdruck mit beweglichen Lettern", "книгопечатание", "Mainz", "Майнц"),
    ("Geoffrey Chaucer", "Джеффри Чосер", 1387, "Literatur", "Литература", "die Canterbury Tales", "«Кентерберийские рассказы»", "England", "Англия"),
    ("Dante Alighieri", "Данте Алигьери", 1321, "Literatur", "Литература", "die Divina Commedia", "«Божественная комедия»", "Florenz", "Флоренция"),
    ("Heinrich II. Plantagenet", "Генрих II Плантагенет", 1170, "England", "Англия", "den Konflikt mit Thomas Becket", "конфликт с Бекетом", "Canterbury", "Кентербери"),
    ("Thomas Becket", "Томас Бекет", 1170, "England", "Англия", "seine Ermordung in Canterbury", "убийство в Кентербери", "Canterbury", "Кентербери"),
    ("Philipp II. August", "Филипп II Август", 1214, "Frankreich", "Франция", "die Schlacht bei Bouvines", "битва при Бувине", "Bouvines", "Бувин"),
    ("Ludwig IX.", "Людовик IX Святой", 1248, "Frankreich", "Франция", "den Siebten Kreuzzug", "седьмой крестовый поход", "Ägypten", "Египет"),
    ("Karl VII.", "Карл VII", 1429, "Hundertjähriger Krieg", "Столетняя война", "die Krönung in Reims", "коронация в Реймсе", "Reims", "Реймс"),
    ("Maximilian I.", "Максимилиан I", 1493, "Habsburg", "Габсбурги", "die Erweiterung habsburgischer Macht", "расширение власти Габсбургов", "Wien", "Вена"),
    ("Lorenzo de' Medici", "Лоренцо Медичи", 1469, "Italien", "Италия", "die Blütezeit von Florenz", "расцвет Флоренции", "Florenz", "Флоренция"),
    ("Jan Žižka", "Ян Жижка", 1420, "Hussitenkriege", "Гуситские войны", "die Wagenburg-Taktik", "тактика вагенбурга", "Tábor", "Табор"),
    ("Basil II.", "Василий II", 1018, "Byzanz", "Византия", "die Unterwerfung Bulgariens", "покорение Болгарии", "Byzanz", "Византия"),
    ("Justinian I.", "Юстиниан I", 529, "Byzanz", "Византия", "den Codex Iustinianus", "Кодекс Юстиниана", "Konstantinopel", "Константинополь"),
    ("Theodora", "Феодора", 532, "Byzanz", "Византия", "die Niederschlagung des Nika-Aufstands", "подавление восстания «Ника»", "Konstantinopel", "Константинополь"),
    ("Leo III.", "Лев III", 730, "Byzanz", "Византия", "den Ikonoklasmus", "иконоборчество", "Konstantinopel", "Константинополь"),
    ("Wladimir der Heilige", "Владимир Святой", 988, "Kiewer Rus", "Киевская Русь", "die Taufe der Kiewer Rus", "крещение Руси", "Kiew", "Киев"),
    ("Jaroslaw der Weise", "Ярослав Мудрый", 1054, "Kiewer Rus", "Киевская Русь", "den Höhepunkt der Kiewer Rus", "расцвет Киевской Руси", "Kiew", "Киев"),
    ("Alfred der Große", "Альфред Великий", 878, "England", "Англия", "den Frieden von Wedmore", "мир в Ведморе", "Wessex", "Уэссекс"),
    ("Knut der Große", "Кнуд Великий", 1016, "England", "Англия", "das nordisches Weltreich", "северная морская империя", "London", "Лондон"),
    ("Harald Hardrada", "Харальд Суровый", 1066, "Wikinger", "Викинги", "die Schlacht bei Stamford Bridge", "битва при Стамфорд-Бридж", "Yorkshire", "Йоркшир"),
    ("Leif Eriksson", "Лейф Эрикссон", 1000, "Wikinger", "Викинги", "die Entdeckung Vinlands", "открытие Винланда", "Vinland", "Винланд"),
    ("Rollo", "Ролло", 911, "Normannen", "Нормандия", "den Vertrag von Saint-Clair-sur-Epte", "договор в Нормандии", "Normandie", "Нормандия"),
    ("Heinrich I.", "Генрих I Птицелов", 919, "Ottonen", "Оттоны", "den Beginn der ottonischen Dynastie", "начало династии Оттонов", "Quedlinburg", "Кведлинбург"),
    ("Otto II.", "Оттон II", 983, "Ottonen", "Оттоны", "die Niederlage bei Cotrone", "поражение при Котроне", "Kalabrien", "Калабрия"),
    ("Heinrich III.", "Генрих III", 1046, "Salier", "Салии", "die Einsetzung deutscher Päpste", "поставление немецких пап", "Rom", "Рим"),
    ("Heinrich V.", "Генрих V", 1122, "Salier", "Салии", "den Wormser Konkordat", "Вормсский конкордат", "Worms", "Вормс"),
    ("Konrad II.", "Конрад II", 1027, "Salier", "Салии", "die Krönung zum Kaiser in Rom", "императорская коронация", "Rom", "Рим"),
    ("Friedrich II. Hohenstaufen", "Фридрих II Штауфен", 1228, "Staufer", "Штауфены", "den Sechsten Kreuzzug", "шестой крестовый поход", "Jerusalem", "Иерусалим"),
    ("Konradin", "Конрадин", 1268, "Staufer", "Штауфены", "die Hinrichtung in Neapel", "казнь в Неаполе", "Neapel", "Неаполь"),
    ("Rudolf I. von Habsburg", "Рудольф I Габсбург", 1273, "Habsburg", "Габсбурги", "die Wahl zum römisch-deutschen König", "избрание римско-германским королём", "Frankfurt", "Франкфурт"),
    ("Karl IV.", "Карл IV", 1356, "Luxemburger", "Люксембурги", "die Goldene Bulle", "Золотая булла", "Nürnberg", "Нюрнберг"),
    ("Sigismund", "Сигизмунд", 1414, "Luxemburger", "Люксембурги", "das Konstanzer Konzil", "Констанцский собор", "Konstanz", "Констанц"),
    ("Wenzel von Böhmen", "Вацлав", 1400, "Böhmen", "Чехия", "die Hussiten-Vorgeschichte", "преддверие гуситских войн", "Prag", "Прага"),
    ("Bolesław Chrobry", "Болеслав Храбрый", 1025, "Polen", "Польша", "die Krönung zum polnischen König", "коронация польского короля", "Gnesen", "Гнезно"),
    ("Kasimir III. der Große", "Казимир III Великий", 1333, "Polen", "Польша", "die Stärkung Polens", "укрепление Польши", "Krakau", "Краков"),
    ("Stephan Dušan", "Стефан Душан", 1346, "Serbien", "Сербия", "die Krönung zum Zar der Serben", "коронация царя сербов", "Skopje", "Скопье"),
    ("Ivan Asen II.", "Иван Асен II", 1230, "Bulgarien", "Болгария", "den Höhepunkt des Zweiten Bulgarischen Reiches", "расцвет Второго Болгарского царства", "Tarnowo", "Тырново"),
    ("Béla IV.", "Бела IV", 1241, "Ungarn", "Венгрия", "die Mongolen-Invasion", "монгольское нашествие", "Ungarn", "Венгрия"),
    ("Matthias Corvinus", "Матьяш Корвин", 1458, "Ungarn", "Венгрия", "die Renaissance-Hofhaltung in Buda", "ренессансный двор в Буде", "Buda", "Буда"),
    ("Stefan der Große", "Стефан Великий", 1457, "Moldawien", "Молдавия", "die Stärkung der Moldau", "укрепление Молдавии", "Suceava", "Сучава"),
    ("Vlad III. Drăculea", "Влад Цепеш", 1462, "Walachei", "Валахия", "den Widerstand gegen die Osmanen", "сопротивление османам", "Târgoviște", "Тырговиште"),
    ("Skanderbeg", "Скандербег", 1443, "Albanien", "Албания", "den Aufstand gegen die Osmanen", "восстание против османов", "Krujë", "Круя"),
    ("Murad II.", "Мурад II", 1444, "Osmanen", "Османы", "die Schlacht bei Varna", "битва при Варне", "Varna", "Варна"),
    ("Bayezid I.", "Баязид I", 1402, "Osmanen", "Османы", "die Niederlage gegen Timur", "поражение от Тамерлана", "Ankara", "Анкара"),
    ("Suleiman der Prächtige", "Сулейман Великолепный", 1520, "Osmanen", "Османы", "die Belagerung von Wien 1529", "осада Вены 1529", "Wien", "Вена"),
    ("Osman I.", "Осман I", 1299, "Osmanen", "Османы", "die Gründung des Osmanischen Reiches", "основание Османской империи", "Bursa", "Бурса"),
    ("Alp Arslan", "Альп-Арслан", 1071, "Seldschuken", "Сельджуки", "die Schlacht von Manzikert", "битва при Манцикерте", "Manzikert", "Манцикерт"),
    ("Malek-Schah I.", "Малик-Шах I", 1087, "Seldschuken", "Сельджуки", "den Höhepunkt des Seldschukenreichs", "расцвет сельджукского государства", "Isfahan", "Исфахан"),
    ("Al-Mansur", "аль-Мансур", 786, "Kalifat", "Халифат", "die Gründung von Bagdad", "основание Багдада", "Bagdad", "Багдад"),
    ("Harun al-Raschid", "Харун ар-Рашид", 786, "Kalifat", "Халифат", "das Abbasiden-Kalifat", "эпоха Аббасидов", "Bagdad", "Багдад"),
    ("Baldwin I.", "Балдуин I", 1100, "Kreuzzüge", "Крестовые походы", "die Krönung in Jerusalem", "коронация в Иерусалиме", "Jerusalem", "Иерусалим"),
    ("Gottfried von Bouillon", "Годфруа де Бульон", 1099, "Kreuzzüge", "Крестовые походы", "die Einnahme Jerusalems", "взятие Иерусалима", "Jerusalem", "Иерусалим"),
    ("Raymond von Toulouse", "Раймунд Тулузский", 1099, "Kreuzzüge", "Крестовые походы", "den Ersten Kreuzzug", "первый крестовый поход", "Jerusalem", "Иерусалим"),
    ("Balduin IV.", "Балдуин IV", 1187, "Kreuzzüge", "Крестовые походы", "die Herrschaft trotz Aussatz", "правление при проказе", "Jerusalem", "Иерусалим"),
    ("Hugo von Cluny", "Гуго Клюнийский", 910, "Klosterwesen", "Монастыри", "die Kluni-Reform", "клюнийская реформа", "Cluny", "Клюни"),
    ("Bernhard von Clairvaux", "Бернард Клюнийский", 1146, "Ordenswesen", "Монашество", "den Aufruf zum Zweiten Kreuzzug", "призыв ко второму походу", "Clairvaux", "Клерво"),
    ("Hildegard von Bingen", "Хильдегарда Бингенская", 1151, "Kirche", "Церковь", "ihre Visionen und Schriften", "видения и сочинения", "Bingen", "Бинген"),
    ("Eleanor von Aquitaine", "Алиенора Аквитанская", 1152, "Frankreich", "Франция", "die Heirat mit Heinrich II.", "брак с Генрихом II", "Aquitaine", "Аквитания"),
    ("Philipp IV. der Schöne", "Филипп IV Красивый", 1307, "Frankreich", "Франция", "den Untergang des Templerordens", "разгром тамплиеров", "Paris", "Париж"),
    ("Jakob I. von Aragón", "Хайме I Завоеватель", 1229, "Spanien", "Испания", "die Rückeroberung Mallorcas", "отвоевание Майорки", "Mallorca", "Майорка"),
    ("El Cid", "Сид Кампеадор", 1094, "Spanien", "Испания", "die Eroberung von Valencia", "завоевание Валенсии", "Valencia", "Валенсия"),
    ("Alfonso X. der Weise", "Альфонсо X Мудрый", 1252, "Spanien", "Испания", "die Alfonsinischen Gesetze", "«Сетенарии» Альфонсо X", "Toledo", "Толедо"),
    ("Heinrich der Seefahrer", "Энрике Мореплаватель", 1415, "Portugal", "Португалия", "die Eroberung von Ceuta", "захват Сеуты", "Ceuta", "Сеута"),
    ("Johann I. von Portugal", "Жуан I", 1385, "Portugal", "Португалия", "die Schlacht von Aljubarrota", "битва при Алжубарроте", "Aljubarrota", "Алжубаррота"),
    ("Karl Martell", "Карл Мартелл", 732, "Frankenreich", "Франкское государство", "die Schlacht bei Tours/Poitiers", "битва при Пуатье", "Tours", "Тур"),
    ("Pippin der Kurze", "Пипин Короткий", 751, "Frankenreich", "Франкское государство", "die Gründung des Karolingerreichs", "начало Каролингов", "Soissons", "Суасон"),
    ("Ludwig der Fromme", "Людовик Благочестивый", 843, "Frankenreich", "Франкское государство", "den Vertrag von Verdun", "Верденский договор", "Verdun", "Верден"),
    ("Lothar I.", "Лотарь I", 843, "Frankenreich", "Франкское государство", "die Teilung des Frankenreichs", "раздел империи Карла", "Verdun", "Верден"),
    ("Karl der Kahle", "Карл Лысый", 843, "Frankenreich", "Франкское государство", "den Vertrag von Verdun", "Верденский договор", "Verdun", "Верден"),
    ("Roland", "Роланд", 778, "Frankenreich", "Франкское государство", "die Roncevaux-Schlacht", "Ронсевальское сражение", "Pyrenäen", "Пиренеи"),
    ("Widukind", "Видукинд", 785, "Sachsen", "Саксония", "den Widerstand gegen Karl den Großen", "сопротивление Карлу Великому", "Sachsen", "Саксония"),
    ("Roger II. von Sizilien", "Рожер II", 1130, "Sizilien", "Сицилия", "die Krönung zum König von Sizilien", "коронация короля Сицилии", "Palermo", "Палермо"),
    ("Friedrich II. von Sizilien", "Фридрих II Сицилийский", 1194, "Sizilien", "Сицилия", "die Staufer-Herrschaft auf Sizilien", "власть штауфенов на Сицилии", "Palermo", "Палермо"),
    ("Enrico Dandolo", "Энрико Дандоло", 1204, "Venedig", "Венеция", "die Vierte Kreuzzug-Teilnahme", "участие в четвёртом походе", "Venedig", "Венеция"),
    ("Marco Polo", "Марко Поло", 1271, "Handel", "Торговля", "die Reise nach China", "путешествие в Китай", "Venedig", "Венеция"),
    ("Giovanni di Bicci de' Medici", "Джованни Медичи", 1397, "Florenz", "Флоренция", "die Medici-Bank", "банк Медичи", "Florenz", "Флоренция"),
    ("Girolamo Savonarola", "Джироламо Савонарола", 1497, "Florenz", "Флоренция", "das Feuer der Vanitäten", "костёр пустоты", "Florenz", "Флоренция"),
    ("Petrarca", "Петрарка", 1341, "Humanismus", "Гуманизм", "die Krönung zum Dichter", "коронация поэта", "Rom", "Рим"),
    ("Boccaccio", "Боккаччо", 1353, "Literatur", "Литература", "den Decamerone", "«Декамерон»", "Florenz", "Флоренция"),
    ("Giotto di Bondone", "Джотто", 1305, "Kunst", "Искусство", "die Fresken in Padua", "фрески в Падуе", "Padua", "Падуя"),
    ("Cimabue", "Чимабуэ", 1280, "Kunst", "Искусство", "den Übergang zur Gotik", "переход к готике", "Florenz", "Флоренция"),
    ("Abelard", "Пьер Абеляр", 1117, "Scholastik", "Схоластика", "den Streit mit Bernhard von Clairvaux", "спор с Бернардом", "Paris", "Париж"),
    ("Averroes", "Ибн Рушд", 1198, "Philosophie", "Философия", "die Kommentare zu Aristoteles", "комментарии к Аристотелю", "Córdoba", "Кордова"),
    ("Maimonides", "Маймонид", 1190, "Philosophie", "Философия", "den Führer der Unschlüssigen", "«Путеводитель растерянных»", "Kairo", "Каир"),
    ("Roger Bacon", "Роджер Бэкон", 1267, "Wissenschaft", "Наука", "Experimente mit Optik", "опыты с оптикой", "Oxford", "Оксфорд"),
    ("William von Ockham", "Уильям Оккам", 1320, "Scholastik", "Схоластика", "das Okkams Rasiermesser", "бритва Оккама", "Oxford", "Оксфорд"),
    ("Johannes Duns Scotus", "Иоанн Дунс Скот", 1308, "Scholastik", "Схоластика", "die Formaldistinktion", "формальное различие", "Köln", "Кёльн"),
    ("Papst Clemens V.", "Климент V", 1309, "Avignon", "Авиньон",
     "den Umzug der Kurie nach Avignon", "перенос курии в Авиньон", "Avignon", "Авиньон"),
    ("Papst Gregor XI.", "Григорий XI", 1377, "Kirchengeschichte", "Церковная история",
     "die Rückkehr nach Rom", "возвращение папства в Рим", "Rom", "Рим"),
    ("Papst Urban VI.", "Урбан VI", 1378, "Western Schisma", "Схизма",
     "den Beginn des Westlichen Schismas", "начало Великой схизмы", "Rom", "Рим"),
    ("Papst Martin V.", "Мартин V", 1417, "Western Schisma", "Схизма",
     "das Ende des Westlichen Schismas", "конец схизмы", "Konstanz", "Констанц"),
    ("Jan van Eyck", "Ян ван Эйк", 1432, "Kunst", "Искусство",
     "den Genter Altar", "Гентский алтарь", "Gent", "Гент"),
    ("Hundertjähriger Krieg", "Столетняя война", 1337, "Krieg", "Война",
     "den Ausbruch des Hundertjährigen Krieges", "начало Столетней войны", "Frankreich", "Франция"),
    ("Schwarzer Tod", "Чёрная смерть", 1347, "Seuche", "Чума",
     "die Pestpandemie in Europa", "чумная пандемия в Европе", "Europa", "Европа"),
    ("Bauernaufstand von 1381", "Крестьянское восстание 1381", 1381, "England", "Англия",
     "den Wat-Tyler-Aufstand", "восстание Уота Тайлера", "London", "Лондон"),
    ("Eisenstapel in Calais", "Жакерия", 1358, "Frankreich", "Франция",
     "den Aufstand der Jacquerie", "восстание жакерии", "Frankreich", "Франция"),
    ("Konrad von Marburg", "Конрад Марбург", 1233, "Inquisition", "Инквизиция",
     "die erste deutsche Inquisition", "первая немецкая инквизиция", "Mainz", "Майнц"),
    ("Simon de Montfort", "Симон де Монфор", 1209, "Albigenser", "Альбигойцы",
     "den Albigenserkreuzzug", "крестовый поход против альбигойцев", "Languedoc", "Лангедок"),
    ("Raymond VI. von Toulouse", "Раймунд VI Тулузский", 1209, "Albigenser", "Альбигойцы",
     "den Konflikt mit dem Papst", "конфликт с папой", "Toulouse", "Тулуза"),
    ("Friedrich von Hohenstaufen", "Фридрих Барбаросса", 1155, "Staufer", "Штауфены",
     "die Kaiserkrönung", "императорская коронация", "Rom", "Рим"),
    ("Heinrich VI.", "Генрих VI", 1194, "Staufer", "Штауфены",
     "die Eroberung des Königreichs Sizilien", "завоевание Сицилии", "Palermo", "Палермо"),
    ("Ludwig VII.", "Людовик VII", 1147, "Frankreich", "Франция",
     "den Zweiten Kreuzzug", "второй крестовый поход", "Jerusalem", "Иерусалим"),
    ("Konrad III.", "Конрад III", 1147, "Heiliges Römisches Reich", "Священная Римская империя",
     "den Zweiten Kreuzzug", "второй крестовый поход", "Konstantinopel", "Константинополь"),
    ("Balduin I. von Konstantinopel", "Балдуин I Константинопольский", 1204, "Kreuzzüge", "Крестовые походы",
     "die Eroberung Konstantinopels im Vierten Kreuzzug", "захват Константинополя в 1204", "Konstantinopel", "Константинополь"),
    ("Alexios V. Dukas", "Алексей V Дук", 1204, "Byzanz", "Византия",
     "den Fall Konstantinopels 1204", "падение Константинополя 1204", "Konstantinopel", "Константинополь"),
    ("Michael VIII. Palaiologos", "Михаил VIII Палеолог", 1261, "Byzanz", "Византия",
     "die Rückeroberung Konstantinopels", "возвращение Константинополя", "Konstantinopel", "Константинополь"),
    ("Ivan Kalita", "Иван Калита", 1328, "Russland", "Русь",
     "den Aufstieg Moskaus", "возвышение Москвы", "Moskau", "Москва"),
    ("Dmitri Donskoi", "Дмитрий Донской", 1380, "Russland", "Русь",
     "die Schlacht auf dem Kulikowo-Feld", "Куликовская битва", "Kulikowo", "Куликово"),
    ("Sergius von Radonezh", "Сергий Радонежский", 1378, "Russland", "Русь",
     "die Gründung des Dreifaltigkeitsklosters", "Троицкий монастырь", "Sergijew Possad", "Сергиев Посад"),
    ("Andrei Bogoljubski", "Андрей Боголюбский", 1169, "Russland", "Русь",
     "den Umzug der Hauptstadt nach Wladimir", "столица во Владимире", "Wladimir", "Владимир"),
    ("Alexander Newski", "Александр Невский", 1242, "Russland", "Русь",
     "die Schlacht auf dem Peipussee", "Ледовое побоище", "Peipussee", "Чудское озеро"),
    ("Batu Khan", "Батый", 1240, "Mongolen", "Монголы",
     "die Eroberung Kiews", "разорение Киева", "Kiew", "Киев"),
    ("Genghis Khan", "Чингисхан", 1206, "Mongolen", "Монголы",
     "die Vereinigung der mongolischen Stämme", "объединение монгольских племён", "Karakorum", "Каракорум"),
    ("Kublai Khan", "Хубилай", 1271, "Mongolen", "Монголы",
     "die Yuan-Dynastie in China", "династия Юань", "Peking", "Пекин"),
    ("Hulagu Khan", "Хулагу", 1258, "Mongolen", "Монголы",
     "die Zerstörung Bagdads", "разрушение Багдада", "Bagdad", "Багдад"),
    ("Edward I. Longshanks", "Эдуард I Длинноногий", 1296, "England", "Англия",
     "die Eroberung von Schottland", "завоевание Шотландии", "Schottland", "Шотландия"),
    ("William Wallace", "Уильям Уоллес", 1297, "Schottland", "Шотландия",
     "den Widerstand gegen England", "сопротивление Англии", "Stirling", "Стерлинг"),
    ("Robert the Bruce", "Роберт Брюс", 1314, "Schottland", "Шотландия",
     "die Schlacht von Bannockburn", "битва при Бэннокберне", "Bannockburn", "Бэннокберн"),
    ("Owain Glyndŵr", "Оуэйн Глиндур", 1400, "Wales", "Уэльс",
     "den walisischen Aufstand", "восстание в Уэльсе", "Wales", "Уэльс"),
    ("Richard II.", "Ричард II", 1399, "England", "Англия",
     "seinen Sturz durch Heinrich IV.", "свержение Генрихом IV", "England", "Англия"),
    ("Heinrich IV. (England)", "Генрих IV Болингброк", 1399, "England", "Англия",
     "die Thronbesteigung nach Richard II.", "восшествие после Ричарда II", "England", "Англия"),
    ("Heinrich V.", "Генрих V", 1415, "Hundertjähriger Krieg", "Столетняя война",
     "die Schlacht von Azincourt", "битва при Азенкуре", "Azincourt", "Азенкур"),
    ("Karl VI. von Frankreich", "Карл VI", 1420, "Hundertjähriger Krieg", "Столетняя война",
     "den Vertrag von Troyes", "Труаский договор", "Troyes", "Труа"),
    ("Isabeau von Bayern", "Изабелла Баварская", 1420, "Frankreich", "Франция",
     "die Regentschaft während des Wahnsinns Karls VI.", "регентство при безумии Карла VI", "Paris", "Париж"),
]


def make_entity(s: tuple) -> dict:
    nd, nr, y, cd, cr, ed, er, pd, pr = s
    title_de = f"historische Persönlichkeit ({cd})"
    title_ru = f"историческая личность ({cr})"
    cause_de = f"Spannungen und Machtkämpfe im Bereich {cd}"
    cause_ru = f"напряжённость и борьба за власть в сфере «{cr}»"
    effect_de = f"prägende Wirkung auf {cd} und das europäische Mittelalter"
    effect_ru = f"заметное влияние на «{cr}» и европейское Средневековье"
    expl_de = (
        f"{nd} steht im Zusammenhang mit «{ed}» (um {y}). "
        f"Das Ereignis ist ein Schlüsselmoment für {cd}."
    )
    expl_ru = (
        f"{nr} связан(а) с событием «{er}» (около {y} г.). "
        f"Это важный момент для темы «{cr}»."
    )
    f1_de = (
        f"{nd} gehört zu den bekanntesten Namen des Mittelalters im Themenfeld {cd}. "
        f"Schüler ordnen diese Person oft dem Jahr {y} zu."
    )
    f1_ru = (
        f"{nr} — одно из известных имён Средневековья в теме «{cr}». "
        f"Событие обычно датируют около {y} года."
    )
    f2_de = (
        f"Historisch wird «{ed}» vor allem mit {pd} verbunden. "
        f"Quellen und Chronisten betonen die politische und kulturelle Bedeutung."
    )
    f2_ru = (
        f"Событие «{er}» связывают с регионом {pr}. "
        f"Хроники подчёркивают политическое и культурное значение."
    )
    f3_de = (
        f"Für die Einordnung von {cd} lohnt sich der Vergleich: Ursachen, Verlauf und Folgen von «{ed}». "
        f"So wird das Mittelalter greifbarer als bloße Jahreszahlen."
    )
    f3_ru = (
        f"Для понимания «{cr}» полезно сравнить причины, ход и последствия: «{er}». "
        f"Так Средневековье становится понятнее, чем список дат."
    )
    short_de = ed if len(ed) < 55 else ed[:52] + "…"
    short_ru = er if len(er) < 55 else er[:52] + "…"
    return e(
        nd, nr, y, cd, cr, title_de, title_ru, ed, er, pd, pr,
        cause_de, cause_ru, effect_de, effect_ru, expl_de, expl_ru,
        f1_de, f1_ru, f2_de, f2_ru, f3_de, f3_ru, short_de, short_ru,
    )


def build_seed_entities() -> list[dict]:
    seen_names: set[str] = set()
    out: list[dict] = []
    for s in RAW_SEEDS:
        if s[0] in seen_names:
            continue
        seen_names.add(s[0])
        out.append(make_entity(s))
    return out


SEED_ENTITIES = build_seed_entities()
