import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main_page.dart';

class QuizResultsPage extends StatefulWidget {
  final int userId;
  final int? quizId;
  final int? latestScore;
  final int? totalQuestions;

  const QuizResultsPage({
    super.key,
    required this.userId,
    this.quizId,
    this.latestScore,
    this.totalQuestions,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  List<Map<String, dynamic>> results = [];
  String quizName = '';

  @override
  void initState() {
    super.initState();
    _loadResults();
    if (widget.quizId != null) {
      _loadQuizName();
    }
  }

  void _loadResults() async {
    final loadedResults = await DatabaseHelper.instance.getUserResults(
      widget.userId,
      quizId: widget.quizId,
    );
    setState(() {
      results = loadedResults;
    });
  }

  void _loadQuizName() async {
    if (widget.quizId != null) {
      final quiz = await DatabaseHelper.instance.getQuiz(widget.quizId!);
      setState(() {
        quizName = quiz?['name'] ?? 'Quiz';
      });
    }
  }

  void _clearHistory() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text(
          widget.quizId != null
              ? 'Are you sure you want to clear your $quizName result history?'
              : 'Are you sure you want to clear all your quiz result history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearUserResults(
        widget.userId,
        quizId: widget.quizId,
      );
      _loadResults(); // Refresh the results list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Result history cleared'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizId != null ? '$quizName Results' : 'All Quiz Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Clear History',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.latestScore != null && widget.totalQuestions != null)
              Card(
                child: ListTile(
                  title: Text('Latest $quizName Result'),
                  subtitle: Text(
                    'Score: ${widget.latestScore}/${widget.totalQuestions} '
                        '(${((widget.latestScore! / widget.totalQuestions!) * 100).toStringAsFixed(1)}%)',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.quizId != null ? 'Previous $quizName Results' : 'Previous Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No previous results'))
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final percentage =
                  (result['score'] / result['totalQuestions'] * 100).toStringAsFixed(1);
                  return Card(
                    child: ListTile(
                      title: Text('Score: ${result['score']}/${result['totalQuestions']}'),
                      subtitle: Text(
                        '$percentage% - ${result['date'].substring(0, 10)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(userId: widget.userId),
                    ),
                  );
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}