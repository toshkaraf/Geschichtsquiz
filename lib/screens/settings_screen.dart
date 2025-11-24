import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/question_service.dart';
import '../services/question_test_service.dart';

class SettingsScreen extends StatefulWidget {
  final List<QuizQuestion> allQuestions;
  final Function(List<QuizQuestion>) onFiltersChanged;

  const SettingsScreen({
    super.key,
    required this.allQuestions,
    required this.onFiltersChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedCategory;
  String? _selectedPeriod;
  List<QuizQuestion> _filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    // Warte bis nach dem Build, bevor wir den Callback aufrufen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredQuestions = QuestionService.filterQuestions(
        widget.allQuestions,
        selectedCategory: _selectedCategory,
        selectedPeriod: _selectedPeriod,
      );
    });
    widget.onFiltersChanged(_filteredQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final categories = QuestionService.getUniqueCategories(widget.allQuestions);
    final periods = QuestionService.getUniquePeriods(widget.allQuestions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Kategorie-Filter (Land)
                    const Text(
                      'Land/Kategorie:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Alle Länder'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Alle Länder'),
                        ),
                        ...categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Epoche-Filter
                    const Text(
                      'Epoche:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPeriod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Alle Epochen'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Alle Epochen'),
                        ),
                        ...periods.map((period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(period),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Statistik-Karte
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistik',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Gesamt',
                          widget.allQuestions.length.toString(),
                          Icons.quiz,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Gefiltert',
                          _filteredQuestions.length.toString(),
                          Icons.filter_list,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Test-Button
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тестирование',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _runQuestionTest,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Проверить все вопросы'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Start-Button
            ElevatedButton(
              onPressed: _filteredQuestions.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Quiz starten',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Future<void> _runQuestionTest() async {
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final problematicQuestions = await QuestionTestService.testAllQuestions();
      final statistics = await QuestionTestService.getStatistics();

      // Выводим результаты в консоль
      _printTestResults(problematicQuestions, statistics);

      if (!mounted) return;
      Navigator.of(context).pop(); // Закрываем индикатор загрузки

      // Показываем результаты
      showDialog(
        context: context,
        builder: (context) => _TestResultsDialog(
          problematicQuestions: problematicQuestions,
          statistics: statistics,
        ),
      );
    } catch (e) {
      // Выводим ошибку в консоль
      print('❌ Ошибка при тестировании: $e');
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Закрываем индикатор загрузки
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text('Ошибка при тестировании: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _printTestResults(
    List<QuestionTestResult> problematicQuestions,
    Map<String, dynamic> statistics,
  ) {
    final totalQuestions = statistics['totalQuestions'] as int;
    final validQuestions = statistics['validQuestions'] as int;
    final problematicCount = statistics['problematicQuestions'] as int;
    final optionsDistribution = statistics['optionsDistribution'] as Map<int, int>;

    print('\n${'=' * 60}');
    print('РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ ВОПРОСОВ');
    print('${'=' * 60}');
    print('Всего вопросов: $totalQuestions');
    print('Корректных вопросов: $validQuestions');
    print('Проблемных вопросов: $problematicCount');
    print('${'=' * 60}');
    
    if (optionsDistribution.isNotEmpty) {
      print('\nРаспределение по количеству вариантов ответов:');
      final sortedKeys = optionsDistribution.keys.toList()..sort();
      for (final count in sortedKeys) {
        final questionCount = optionsDistribution[count]!;
        print('  $count вариант(ов): $questionCount вопрос(ов)');
      }
    }
    
    if (problematicQuestions.isEmpty) {
      print('\n✅ Все вопросы корректны! Проблем не найдено.');
    } else {
      print('\n⚠️ ПРОБЛЕМНЫЕ ВОПРОСЫ ($problematicCount):');
      print('${'=' * 60}');
      
      for (final result in problematicQuestions) {
        print('\nID: ${result.questionId}');
        print('Вопрос: ${result.questionText}');
        print('Вариантов ответов: ${result.optionsCountDe} DE / ${result.optionsCountRu} RU');
        if (result.issue != null) {
          print('Проблема: ${result.issue}');
        }
        print('${'-' * 60}');
      }
    }
    
    print('\n${'=' * 60}\n');
  }
}

class _TestResultsDialog extends StatelessWidget {
  final List<QuestionTestResult> problematicQuestions;
  final Map<String, dynamic> statistics;

  const _TestResultsDialog({
    required this.problematicQuestions,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuestions = statistics['totalQuestions'] as int;
    final validQuestions = statistics['validQuestions'] as int;
    final problematicCount = statistics['problematicQuestions'] as int;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Результаты теста'),
              backgroundColor: problematicCount > 0 ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Статистика
                    Card(
                      color: problematicCount > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Статистика',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: problematicCount > 0 ? Colors.orange.shade900 : Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow('Всего вопросов:', totalQuestions.toString()),
                            _buildStatRow('Корректных:', validQuestions.toString(), Colors.green),
                            _buildStatRow('Проблемных:', problematicCount.toString(), Colors.orange),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Список проблемных вопросов
                    if (problematicQuestions.isEmpty)
                      const Card(
                        color: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Все вопросы корректны!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Text(
                        'Проблемные вопросы (${problematicQuestions.length}):',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...problematicQuestions.map((result) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.orange.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text(
                            'ID ${result.questionId}: ${result.questionText}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Вариантов: ${result.optionsCountDe} DE / ${result.optionsCountRu} RU'),
                              if (result.issue != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  result.issue!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}



