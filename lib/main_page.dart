import 'package:flutter/material.dart';
import 'question_list.dart';
import 'quiz_results.dart';

class MainPage extends StatelessWidget {
  final int userId;

  const MainPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListPage(userId: userId),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizResultsPage(userId: userId),
                  ),
                );
              },
              child: const Text('View Results'),
            ),
          ],
        ),
      ),
    );
  }
}