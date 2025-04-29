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

    // Insert sample questions
    await db.insert('questions', {
      'question': 'What is the capital of France?',
      'options': jsonEncode(['Paris', 'London', 'Berlin', 'Madrid']),
      'correctAnswer': 0
    });
    await db.insert('questions', {
      'question': 'Which planet is known as the Red Planet?',
      'options': jsonEncode(['Jupiter', 'Mars', 'Venus', 'Mercury']),
      'correctAnswer': 1
    });
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