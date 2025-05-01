import 'package:flutter/material.dart';
import 'QuestionsDetails.dart';
import 'quiz_results.dart';
import 'database_helper.dart';
import 'login.dart';

class MainPage extends StatefulWidget {
  final int userId;

  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = true;
  final List<String> categories = ['Popular', 'Newest'];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() async {
    print('Loading quizzes...');
    final loadedQuizzes = await DatabaseHelper.instance.getQuizzes();
    print('Loaded quizzes: $loadedQuizzes');
    setState(() {
      quizzes = loadedQuizzes;
      isLoading = false;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Helper function to determine the icon based on quiz name
  IconData _getIconForQuiz(String quizName) {
    final name = quizName.toLowerCase();
    if (name.contains('general')) {
      return Icons.lightbulb;
    } else if (name.contains('history')) {
      return Icons.book;
    } else if (name.contains('programming')) {
      return Icons.code;
    } else if (name.contains('science')) {
      return Icons.science;
    } else {
      return Icons.quiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's test your knowledge",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search quizzes...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Chip(
                      label: Text(categories[index]),
                      backgroundColor:
                      index == 0 ? Colors.blue[100] : Colors.white,
                      labelStyle: TextStyle(
                        color: index == 0 ? Colors.blue : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[200]!, Colors.blue[400]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _getIconForQuiz(quiz['name']),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      title: Text(quiz['name']),
                      subtitle: const Text('1 hour 15 min'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text('4.8'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuestionsDetailsPage(
                              userId: widget.userId,
                              quizId: quiz['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizResultsPage(userId: widget.userId),
                    ),
                  );
                },
                child: const Text('View Results'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}