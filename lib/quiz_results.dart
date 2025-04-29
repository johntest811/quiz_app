import 'package:flutter/material.dart';
import '/database_helper.dart';
import 'main_page.dart';

class QuizResultsPage extends StatefulWidget {
  final int userId;
  final int? latestScore;
  final int? totalQuestions;

  const QuizResultsPage({
    super.key,
    required this.userId,
    this.latestScore,
    this.totalQuestions,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() async {
    final loadedResults = await DatabaseHelper.instance.getUserResults(widget.userId);
    setState(() {
      results = loadedResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.latestScore != null && widget.totalQuestions != null)
              Card(
                child: ListTile(
                  title: const Text('Latest Result'),
                  subtitle: Text(
                    'Score: ${widget.latestScore}/${widget.totalQuestions} '
                        '(${((widget.latestScore! / widget.totalQuestions!) * 100).toStringAsFixed(1)}%)',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Previous Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No previous results'))
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final percentage = (result['score'] / result['totalQuestions'] * 100).toStringAsFixed(1);
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