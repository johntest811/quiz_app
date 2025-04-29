// File: lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        correctAnswer INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Insert 20 sample questions
    final questions = [
      {
        'question': 'What is the capital of France?',
        'options': jsonEncode(['Paris', 'London', 'Berlin', 'Madrid']),
        'correctAnswer': 0
      },
      {
        'question': 'Which planet is known as the Red Planet?',
        'options': jsonEncode(['Jupiter', 'Mars', 'Venus', 'Mercury']),
        'correctAnswer': 1
      },
      {
        'question': 'What is 2 + 2?',
        'options': jsonEncode(['3', '4', '5', '6']),
        'correctAnswer': 1
      },
      {
        'question': 'Who wrote "Romeo and Juliet"?',
        'options': jsonEncode(['Shakespeare', 'Dickens', 'Austen', 'Hemingway']),
        'correctAnswer': 0
      },
      {
        'question': 'What is the largest mammal?',
        'options': jsonEncode(['Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus']),
        'correctAnswer': 1
      },
      {
        'question': 'Which element has the symbol H?',
        'options': jsonEncode(['Helium', 'Hydrogen', 'Hafnium', 'Holmium']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the currency of Japan?',
        'options': jsonEncode(['Yuan', 'Yen', 'Won', 'Ringgit']),
        'correctAnswer': 1
      },
      {
        'question': 'Which country hosted the 2016 Olympics?',
        'options': jsonEncode(['China', 'Brazil', 'Russia', 'Japan']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the boiling point of water in Celsius?',
        'options': jsonEncode(['50', '75', '100', '125']),
        'correctAnswer': 2
      },
      {
        'question': 'Who painted the Mona Lisa?',
        'options': jsonEncode(['Van Gogh', 'Da Vinci', 'Picasso', 'Monet']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the longest river in the world?',
        'options': jsonEncode(['Amazon', 'Nile', 'Yangtze', 'Mississippi']),
        'correctAnswer': 1
      },
      {
        'question': 'Which gas is most abundant in Earth’s atmosphere?',
        'options': jsonEncode(['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the capital of Australia?',
        'options': jsonEncode(['Sydney', 'Melbourne', 'Canberra', 'Perth']),
        'correctAnswer': 2
      },
      {
        'question': 'Which scientist developed the theory of relativity?',
        'options': jsonEncode(['Newton', 'Einstein', 'Galileo', 'Hawking']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the smallest unit of life?',
        'options': jsonEncode(['Atom', 'Molecule', 'Cell', 'Organ']),
        'correctAnswer': 2
      },
      {
        'question': 'Which continent is the Sahara Desert located on?',
        'options': jsonEncode(['Asia', 'Africa', 'Australia', 'South America']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the chemical formula for water?',
        'options': jsonEncode(['CO2', 'H2O', 'NaCl', 'O2']),
        'correctAnswer': 1
      },
      {
        'question': 'Which language is primarily spoken in Brazil?',
        'options': jsonEncode(['Spanish', 'Portuguese', 'English', 'French']),
        'correctAnswer': 1
      },
      {
        'question': 'What is the tallest mountain in the world?',
        'options': jsonEncode(['K2', 'Kangchenjunga', 'Everest', 'Lhotse']),
        'correctAnswer': 2
      },
      {
        'question': 'Which organ is responsible for pumping blood?',
        'options': jsonEncode(['Liver', 'Heart', 'Lung', 'Kidney']),
        'correctAnswer': 1
      },
    ];

    for (var question in questions) {
      await db.insert('questions', question);
    }
  }

  Future<bool> registerUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': _hashPassword(password),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, _hashPassword(password)],
    );
    return result.isNotEmpty ? result.first : null;
  }

  String _hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    final db = await database;
    return await db.query('questions');
  }

  Future<void> saveResult(int userId, int score, int totalQuestions) async {
    final db = await database;
    await db.insert('results', {
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserResults(int userId) async {
    final db = await database;
    return await db.query(
      'results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}