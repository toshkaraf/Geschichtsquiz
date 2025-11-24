import 'package:flutter/material.dart';
import 'models/quiz_question.dart';
import 'screens/start_screen.dart';
import 'screens/quiz_screen.dart';
import 'services/question_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const QuizHomePage(),
      routes: {
        '/quiz': (context) => const QuizWrapper(),
      },
    );
  }
}

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartScreen();
  }
}

class QuizWrapper extends StatefulWidget {
  const QuizWrapper({super.key});

  @override
  State<QuizWrapper> createState() => _QuizWrapperState();
}

class _QuizWrapperState extends State<QuizWrapper> {
  List<QuizQuestion> availableQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.loadAllQuestions();
      setState(() {
        availableQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onQuestionUsed(QuizQuestion question) {
    setState(() {
      availableQuestions.remove(question);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return QuizScreen(
      availableQuestions: availableQuestions,
      onQuestionUsed: _onQuestionUsed,
    );
  }
}
