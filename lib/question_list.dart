import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'quiz_results.dart';

class QuestionListPage extends StatefulWidget {
  final int userId;
  final int quizId;

  const QuestionListPage({super.key, required this.userId, required this.quizId});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  List<int?> selectedAnswers = [];
  String quizName = '';
  int secondsElapsed = 0;
  bool isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadQuizName();
    _startTimer();
  }

  void _loadQuestions() async {
    final loadedQuestions = await DatabaseHelper.instance.getQuestions(widget.quizId);
    setState(() {
      questions = loadedQuestions;
      selectedAnswers = List.filled(questions.length, null);
    });
  }

  void _loadQuizName() async {
    final quiz = await DatabaseHelper.instance.getQuiz(widget.quizId);
    setState(() {
      quizName = quiz?['name'] ?? 'Quiz';
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !isTimerRunning) return false;
      setState(() {
        secondsElapsed++;
      });
      return true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _submitAnswer(int selectedIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = selectedIndex;
      if (selectedIndex == questions[currentQuestionIndex]['correctAnswer']) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _submitQuiz() {
    isTimerRunning = false;
    DatabaseHelper.instance.saveResult(
      widget.userId,
      widget.quizId,
      score,
      questions.length,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsPage(
          userId: widget.userId,
          quizId: widget.quizId,
          latestScore: score,
          totalQuestions: questions.length,
        ),
      ),
    );
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(quizName),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formatTime(secondsElapsed),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                questions.length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == currentQuestionIndex
                          ? Colors.blue
                          : (index < currentQuestionIndex ? Colors.grey : Colors.grey[300]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                onChanged: (value) => _submitAnswer(index),
                activeColor: Colors.blue,
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  TextButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous', style: TextStyle(color: Colors.blue)),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: currentQuestionIndex == questions.length - 1 &&
                      selectedAnswers[currentQuestionIndex] != null
                      ? _submitQuiz
                      : (selectedAnswers[currentQuestionIndex] != null ? _nextQuestion : null),
                  child: Text(
                    currentQuestionIndex == questions.length - 1 ? 'Submit Quiz' : 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}