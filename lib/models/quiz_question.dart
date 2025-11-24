class QuizQuestion {
  final int id;
  final String questionDe;
  final String questionRu;
  final List<String> optionsDe;
  final List<String> optionsRu;
  final int correctAnswerIndex;
  final List<String> factsDe;
  final List<String> factsRu;
  final String? explanationDe;
  final String? explanationRu;
  final String? category;
  final String? period;
  final String? difficulty;
  final String? type;
  final List<String>? tags;

  QuizQuestion({
    required this.id,
    required this.questionDe,
    required this.questionRu,
    required this.optionsDe,
    required this.optionsRu,
    required this.correctAnswerIndex,
    required this.factsDe,
    required this.factsRu,
    this.explanationDe,
    this.explanationRu,
    this.category,
    this.period,
    this.difficulty,
    this.type,
    this.tags,
  });

  String get question {
    return questionDe;
  }

  String get questionTranslated {
    return questionRu;
  }

  List<String> get options {
    return optionsDe;
  }

  List<String> get optionsTranslated {
    return optionsRu;
  }

  List<String> get facts {
    return factsDe;
  }

  List<String> get factsTranslated {
    return factsRu;
  }

  String? get explanation {
    return explanationDe;
  }

  String? get explanationTranslated {
    return explanationRu;
  }
}


