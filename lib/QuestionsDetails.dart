import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'question_list.dart';

class QuestionsDetailsPage extends StatefulWidget {
  final int userId;
  final int quizId;

  const QuestionsDetailsPage({super.key, required this.userId, required this.quizId});

  @override
  State<QuestionsDetailsPage> createState() => _QuestionsDetailsPageState();
}

class _QuestionsDetailsPageState extends State<QuestionsDetailsPage> {
  int questionCount = 0;
  String quizName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  void _loadQuizDetails() async {
    final questions = await DatabaseHelper.instance.getQuestions(widget.quizId);
    final quiz = await DatabaseHelper.instance.getQuiz(widget.quizId);
    setState(() {
      questionCount = questions.length;
      quizName = quiz?['name'] ?? 'Quiz';
      isLoading = false;
    });
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionListPage(
          userId: widget.userId,
          quizId: widget.quizId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('$quizName Details'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quizName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text('4.8'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'GET 100 Points',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.question_answer, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text('$questionCount Question'),
                  ],
                ),
                Column(
                  children: const [
                    Icon(Icons.timer, color: Colors.blue),
                    SizedBox(height: 8),
                    Text('1 hour 15 min'),
                  ],
                ),
                Column(
                  children: const [
                    Icon(Icons.star, color: Colors.blue),
                    SizedBox(height: 8),
                    Text('Win 10 star'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Brief explanation about this quiz',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please read the text below carefully so you can understand it\n\n'
                  '• 10 point awarded for a correct answer and no marks for an incorrect answer\n'
                  '• Tap on the options to select the correct answer\n'
                  '• Tap on the bookmark icon to save to interesting quiz\n'
                  '• Click submit if you are sure you want to complete all the quizzes',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _startQuiz,
                child: const Text('Start Quiz'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}