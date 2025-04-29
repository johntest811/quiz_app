import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'quiz_results.dart';

class QuestionListPage extends StatefulWidget {
  final int userId;

  const QuestionListPage({super.key, required this.userId});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  List<int?> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    final loadedQuestions = await DatabaseHelper.instance.getQuestions();
    setState(() {
      questions = loadedQuestions;
      selectedAnswers = List.filled(questions.length, null);
    });
  }

  void _submitAnswer(int selectedIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = selectedIndex;
      if (selectedIndex == questions[currentQuestionIndex]['correctAnswer']) {
        score++;
      }

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        DatabaseHelper.instance.saveResult(widget.userId, score, questions.length);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultsPage(
              userId: widget.userId,
              latestScore: score,
              totalQuestions: questions.length,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];
    final options = jsonDecode(question['options']) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(options.length, (index) {
              return RadioListTile<int>(
                title: Text(options[index]),
                value: index,
                groupValue: selectedAnswers[currentQuestionIndex],
                onChanged: selectedAnswers[currentQuestionIndex] == null
                    ? (value) => _submitAnswer(index)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}