import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/question_service.dart';

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
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 12 : 16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 16 : 24),
                    // Kategorie-Filter (Land)
                    Text(
                      'Land/Kategorie:',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 6 : 8),
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
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 16 : 24),
                    // Epoche-Filter
                    Text(
                      'Epoche:',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 6 : 8),
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
            SizedBox(height: MediaQuery.of(context).size.width < 400 ? 12 : 16),
            // Statistik-Karte
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400 ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 12 : 16),
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
            SizedBox(height: MediaQuery.of(context).size.width < 400 ? 16 : 24),
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
              child: Text(
                'Quiz starten',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 400 ? 18 : 20,
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
            fontSize: MediaQuery.of(context).size.width < 400 ? 24 : 28,
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
}



