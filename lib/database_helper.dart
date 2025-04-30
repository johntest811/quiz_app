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

    print('Initializing database at path: $path');

    // Reset database for testing (remove in production)
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Check if all required tables exist
        var tablesToCheck = ['users', 'quizzes', 'questions', 'results'];
        bool allTablesExist = true;

        for (var table in tablesToCheck) {
          var tableExists = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='$table'"
          );
          if (tableExists.isEmpty) {
            print('Table $table does not exist.');
            allTablesExist = false;
            break;
          }
        }

        if (!allTablesExist) {
          print('Some tables are missing. Ensuring schema...');
          await _createDB(db, 1);
        } else {
          print('All required tables exist.');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    print('Ensuring database schema...');

    // Helper function to check if a table exists
    Future<bool> tableExists(String tableName) async {
      var result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'"
      );
      return result.isNotEmpty;
    }

    // Helper function to check if a column exists in a table
    Future<bool> columnExists(String tableName, String columnName) async {
      var result = await db.rawQuery('PRAGMA table_info($tableName)');
      bool exists = result.any((column) => column['name'].toString().toLowerCase() == columnName.toLowerCase());
      print('Checking if column $columnName exists in $tableName: $exists');
      return exists;
    }

    // Create users table if it doesn't exist
    if (!(await tableExists('users'))) {
      print('Creating users table...');
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    } else {
      print('Users table already exists.');
    }

    // Create quizzes table if it doesn't exist
    if (!(await tableExists('quizzes'))) {
      print('Creating quizzes table...');
      await db.execute('''
        CREATE TABLE quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

      // Insert quizzes
      final quizzes = [
        {'name': 'General Knowledge'},
        {'name': 'Programming'},
        {'name': 'History'},
        {'name': 'Science'},
      ];

      for (var quiz in quizzes) {
        await db.insert('quizzes', quiz);
      }
    } else {
      print('Quizzes table already exists.');
    }

    // Handle questions table: create or migrate
    if (!(await tableExists('questions'))) {
      print('Creating questions table...');
      await db.execute('''
        CREATE TABLE questions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quizId INTEGER NOT NULL,
          question TEXT NOT NULL,
          options TEXT NOT NULL,
          correctAnswer INTEGER NOT NULL,
          FOREIGN KEY (quizId) REFERENCES quizzes (id)
        )
      ''');

      // Insert questions for each quiz
      final questions = [
        // Quiz 1: General Knowledge (20 questions)
        {
          'quizId': 1,
          'question': 'What is the capital of France?',
          'options': jsonEncode(['Paris', 'London', 'Berlin', 'Madrid']),
          'correctAnswer': 0
        },
        {
          'quizId': 1,
          'question': 'Which planet is known as the Red Planet?',
          'options': jsonEncode(['Jupiter', 'Mars', 'Venus', 'Mercury']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is 2 + 2?',
          'options': jsonEncode(['3', '4', '5', '6']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'Who wrote "Romeo and Juliet"?',
          'options': jsonEncode(['Shakespeare', 'Dickens', 'Austen', 'Hemingway']),
          'correctAnswer': 0
        },
        {
          'quizId': 1,
          'question': 'What is the largest mammal?',
          'options': jsonEncode(['Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'Which element has the symbol H?',
          'options': jsonEncode(['Helium', 'Hydrogen', 'Hafnium', 'Holmium']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the currency of Japan?',
          'options': jsonEncode(['Yuan', 'Yen', 'Won', 'Ringgit']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'Which country hosted the 2016 Olympics?',
          'options': jsonEncode(['China', 'Brazil', 'Russia', 'Japan']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the boiling point of water in Celsius?',
          'options': jsonEncode(['50', '75', '100', '125']),
          'correctAnswer': 2
        },
        {
          'quizId': 1,
          'question': 'Who painted the Mona Lisa?',
          'options': jsonEncode(['Van Gogh', 'Da Vinci', 'Picasso', 'Monet']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the longest river in the world?',
          'options': jsonEncode(['Amazon', 'Nile', 'Yangtze', 'Mississippi']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'Which gas is most abundant in Earth’s atmosphere?',
          'options': jsonEncode(['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the capital of Australia?',
          'options': jsonEncode(['Sydney', 'Melbourne', 'Canberra', 'Perth']),
          'correctAnswer': 2
        },
        {
          'quizId': 1,
          'question': 'Which scientist developed the theory of relativity?',
          'options': jsonEncode(['Newton', 'Einstein', 'Galileo', 'Hawking']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the smallest unit of life?',
          'options': jsonEncode(['Atom', 'Molecule', 'Cell', 'Organ']),
          'correctAnswer': 2
        },
        {
          'quizId': 1,
          'question': 'Which continent is the Sahara Desert located on?',
          'options': jsonEncode(['Asia', 'Africa', 'Australia', 'South America']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the chemical formula for water?',
          'options': jsonEncode(['CO2', 'H2O', 'NaCl', 'O2']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'Which language is primarily spoken in Brazil?',
          'options': jsonEncode(['Spanish', 'Portuguese', 'English', 'French']),
          'correctAnswer': 1
        },
        {
          'quizId': 1,
          'question': 'What is the tallest mountain in the world?',
          'options': jsonEncode(['K2', 'Kangchenjunga', 'Everest', 'Lhotse']),
          'correctAnswer': 2
        },
        {
          'quizId': 1,
          'question': 'Which organ is responsible for pumping blood?',
          'options': jsonEncode(['Liver', 'Heart', 'Lung', 'Kidney']),
          'correctAnswer': 1
        },
        // Quiz 2: Programming (5 questions)
        {
          'quizId': 2,
          'question': 'Which language is primarily used for web development?',
          'options': jsonEncode(['Python', 'Java', 'JavaScript', 'C++']),
          'correctAnswer': 2
        },
        {
          'quizId': 2,
          'question': 'What does CSS stand for?',
          'options': jsonEncode([
            'Computer Style Sheets',
            'Cascading Style Sheets',
            'Creative Style System',
            'Coded Style Syntax'
          ]),
          'correctAnswer': 1
        },
        {
          'quizId': 2,
          'question': 'Which keyword is used to define a function in Python?',
          'options': jsonEncode(['func', 'define', 'def', 'function']),
          'correctAnswer': 2
        },
        {
          'quizId': 2,
          'question': 'What is the purpose of a "for" loop?',
          'options': jsonEncode([
            'To declare variables',
            'To iterate over a sequence',
            'To define a class',
            'To handle exceptions'
          ]),
          'correctAnswer': 1
        },
        {
          'quizId': 2,
          'question': 'Which symbol represents a single-line comment in JavaScript?',
          'options': jsonEncode(['#', '//', '/*', '--']),
          'correctAnswer': 1
        },
        // Quiz 3: History (5 questions)
        {
          'quizId': 3,
          'question': 'Who was the first President of the United States?',
          'options': jsonEncode([
            'Abraham Lincoln',
            'George Washington',
            'Thomas Jefferson',
            'John Adams'
          ]),
          'correctAnswer': 1
        },
        {
          'quizId': 3,
          'question': 'In which year did World War II end?',
          'options': jsonEncode(['1943', '1944', '1945', '1946']),
          'correctAnswer': 2
        },
        {
          'quizId': 3,
          'question': 'Which ancient civilization built the Pyramids of Giza?',
          'options': jsonEncode(['Roman', 'Greek', 'Egyptian', 'Mayan']),
          'correctAnswer': 2
        },
        {
          'quizId': 3,
          'question': 'Who was the leader of the Soviet Union during WWII?',
          'options': jsonEncode([
            'Lenin',
            'Stalin',
            'Khrushchev',
            'Gorbachev'
          ]),
          'correctAnswer': 1
        },
        {
          'quizId': 3,
          'question': 'Which event marked the start of the French Revolution?',
          'options': jsonEncode([
            'Storming of the Bastille',
            'Battle of Waterloo',
            'Execution of Louis XVI',
            'Reign of Terror'
          ]),
          'correctAnswer': 0
        },
        // Quiz 4: Science (5 questions)
        {
          'quizId': 4,
          'question': 'What is the primary source of energy for Earth?',
          'options': jsonEncode(['Moon', 'Sun', 'Wind', 'Geothermal']),
          'correctAnswer': 1
        },
        {
          'quizId': 4,
          'question': 'Which gas is essential for human respiration?',
          'options': jsonEncode(['Nitrogen', 'Oxygen', 'Carbon Dioxide', 'Helium']),
          'correctAnswer': 1
        },
        {
          'quizId': 4,
          'question': 'What is the basic unit of heredity in living organisms?',
          'options': jsonEncode(['Cell', 'Gene', 'Protein', 'Enzyme']),
          'correctAnswer': 1
        },
        {
          'quizId': 4,
          'question': 'Which planet is closest to the Sun?',
          'options': jsonEncode(['Venus', 'Mercury', 'Earth', 'Mars']),
          'correctAnswer': 1
        },
        {
          'quizId': 4,
          'question': 'What is the SI unit of force?',
          'options': jsonEncode(['Watt', 'Joule', 'Newton', 'Pascal']),
          'correctAnswer': 2
        },
      ];

      for (var question in questions) {
        await db.insert('questions', question);
      }
    } else {
      print('Questions table already exists. Checking schema...');
      // Check if quizId column exists
      if (!(await columnExists('questions', 'quizId'))) {
        print('quizId column missing in questions table. Attempting migration...');
        try {
          // Add the quizId column
          await db.execute('ALTER TABLE questions ADD COLUMN quizId INTEGER NOT NULL DEFAULT 0');
          print('Successfully added quizId column.');

          // Since the column was missing, we need to populate it with the correct quizId values
          // For existing data, we can't determine the correct quizId, so we set it to a default value
          // In a production app, you might need to recreate the table or manually assign quizIds
          print('Warning: Existing questions have quizId set to 0. Consider recreating the table for accurate data.');
        } catch (e) {
          print('Error adding quizId column: $e');
          print('Recreating questions table as a fallback...');
          // Fallback: Recreate the table if migration fails
          await db.execute('DROP TABLE questions');
          await db.execute('''
            CREATE TABLE questions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER NOT NULL,
              question TEXT NOT NULL,
              options TEXT NOT NULL,
              correctAnswer INTEGER NOT NULL,
              FOREIGN KEY (quizId) REFERENCES quizzes (id)
            )
          ''');

          // Re-insert questions
          final questions = [
            // Quiz 1: General Knowledge (20 questions)
            {
              'quizId': 1,
              'question': 'What is the capital of France?',
              'options': jsonEncode(['Paris', 'London', 'Berlin', 'Madrid']),
              'correctAnswer': 0
            },
            {
              'quizId': 1,
              'question': 'Which planet is known as the Red Planet?',
              'options': jsonEncode(['Jupiter', 'Mars', 'Venus', 'Mercury']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is 2 + 2?',
              'options': jsonEncode(['3', '4', '5', '6']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'Who wrote "Romeo and Juliet"?',
              'options': jsonEncode(['Shakespeare', 'Dickens', 'Austen', 'Hemingway']),
              'correctAnswer': 0
            },
            {
              'quizId': 1,
              'question': 'What is the largest mammal?',
              'options': jsonEncode(['Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'Which element has the symbol H?',
              'options': jsonEncode(['Helium', 'Hydrogen', 'Hafnium', 'Holmium']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the currency of Japan?',
              'options': jsonEncode(['Yuan', 'Yen', 'Won', 'Ringgit']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'Which country hosted the 2016 Olympics?',
              'options': jsonEncode(['China', 'Brazil', 'Russia', 'Japan']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the boiling point of water in Celsius?',
              'options': jsonEncode(['50', '75', '100', '125']),
              'correctAnswer': 2
            },
            {
              'quizId': 1,
              'question': 'Who painted the Mona Lisa?',
              'options': jsonEncode(['Van Gogh', 'Da Vinci', 'Picasso', 'Monet']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the longest river in the world?',
              'options': jsonEncode(['Amazon', 'Nile', 'Yangtze', 'Mississippi']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'Which gas is most abundant in Earth’s atmosphere?',
              'options': jsonEncode(['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the capital of Australia?',
              'options': jsonEncode(['Sydney', 'Melbourne', 'Canberra', 'Perth']),
              'correctAnswer': 2
            },
            {
              'quizId': 1,
              'question': 'Which scientist developed the theory of relativity?',
              'options': jsonEncode(['Newton', 'Einstein', 'Galileo', 'Hawking']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the smallest unit of life?',
              'options': jsonEncode(['Atom', 'Molecule', 'Cell', 'Organ']),
              'correctAnswer': 2
            },
            {
              'quizId': 1,
              'question': 'Which continent is the Sahara Desert located on?',
              'options': jsonEncode(['Asia', 'Africa', 'Australia', 'South America']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the chemical formula for water?',
              'options': jsonEncode(['CO2', 'H2O', 'NaCl', 'O2']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'Which language is primarily spoken in Brazil?',
              'options': jsonEncode(['Spanish', 'Portuguese', 'English', 'French']),
              'correctAnswer': 1
            },
            {
              'quizId': 1,
              'question': 'What is the tallest mountain in the world?',
              'options': jsonEncode(['K2', 'Kangchenjunga', 'Everest', 'Lhotse']),
              'correctAnswer': 2
            },
            {
              'quizId': 1,
              'question': 'Which organ is responsible for pumping blood?',
              'options': jsonEncode(['Liver', 'Heart', 'Lung', 'Kidney']),
              'correctAnswer': 1
            },
            // Quiz 2: Programming (5 questions)
            {
              'quizId': 2,
              'question': 'Which language is primarily used for web development?',
              'options': jsonEncode(['Python', 'Java', 'JavaScript', 'C++']),
              'correctAnswer': 2
            },
            {
              'quizId': 2,
              'question': 'What does CSS stand for?',
              'options': jsonEncode([
                'Computer Style Sheets',
                'Cascading Style Sheets',
                'Creative Style System',
                'Coded Style Syntax'
              ]),
              'correctAnswer': 1
            },
            {
              'quizId': 2,
              'question': 'Which keyword is used to define a function in Python?',
              'options': jsonEncode(['func', 'define', 'def', 'function']),
              'correctAnswer': 2
            },
            {
              'quizId': 2,
              'question': 'What is the purpose of a "for" loop?',
              'options': jsonEncode([
                'To declare variables',
                'To iterate over a sequence',
                'To define a class',
                'To handle exceptions'
              ]),
              'correctAnswer': 1
            },
            {
              'quizId': 2,
              'question': 'Which symbol represents a single-line comment in JavaScript?',
              'options': jsonEncode(['#', '//', '/*', '--']),
              'correctAnswer': 1
            },
            // Quiz 3: History (5 questions)
            {
              'quizId': 3,
              'question': 'Who was the first President of the United States?',
              'options': jsonEncode([
                'Abraham Lincoln',
                'George Washington',
                'Thomas Jefferson',
                'John Adams'
              ]),
              'correctAnswer': 1
            },
            {
              'quizId': 3,
              'question': 'In which year did World War II end?',
              'options': jsonEncode(['1943', '1944', '1945', '1946']),
              'correctAnswer': 2
            },
            {
              'quizId': 3,
              'question': 'Which ancient civilization built the Pyramids of Giza?',
              'options': jsonEncode(['Roman', 'Greek', 'Egyptian', 'Mayan']),
              'correctAnswer': 2
            },
            {
              'quizId': 3,
              'question': 'Who was the leader of the Soviet Union during WWII?',
              'options': jsonEncode([
                'Lenin',
                'Stalin',
                'Khrushchev',
                'Gorbachev'
              ]),
              'correctAnswer': 1
            },
            {
              'quizId': 3,
              'question': 'Which event marked the start of the French Revolution?',
              'options': jsonEncode([
                'Storming of the Bastille',
                'Battle of Waterloo',
                'Execution of Louis XVI',
                'Reign of Terror'
              ]),
              'correctAnswer': 0
            },
            // Quiz 4: Science (5 questions)
            {
              'quizId': 4,
              'question': 'What is the primary source of energy for Earth?',
              'options': jsonEncode(['Moon', 'Sun', 'Wind', 'Geothermal']),
              'correctAnswer': 1
            },
            {
              'quizId': 4,
              'question': 'Which gas is essential for human respiration?',
              'options': jsonEncode(['Nitrogen', 'Oxygen', 'Carbon Dioxide', 'Helium']),
              'correctAnswer': 1
            },
            {
              'quizId': 4,
              'question': 'What is the basic unit of heredity in living organisms?',
              'options': jsonEncode(['Cell', 'Gene', 'Protein', 'Enzyme']),
              'correctAnswer': 1
            },
            {
              'quizId': 4,
              'question': 'Which planet is closest to the Sun?',
              'options': jsonEncode(['Venus', 'Mercury', 'Earth', 'Mars']),
              'correctAnswer': 1
            },
            {
              'quizId': 4,
              'question': 'What is the SI unit of force?',
              'options': jsonEncode(['Watt', 'Joule', 'Newton', 'Pascal']),
              'correctAnswer': 2
            },
          ];

          for (var question in questions) {
            await db.insert('questions', question);
          }
        }
      } else {
        print('quizId column already exists in questions table.');
      }
    }

    // Create results table if it doesn't exist
    if (!(await tableExists('results'))) {
      print('Creating results table...');
      await db.execute('''
        CREATE TABLE results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          quizId INTEGER NOT NULL,
          score INTEGER NOT NULL,
          totalQuestions INTEGER NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id),
          FOREIGN KEY (quizId) REFERENCES quizzes (id)
        )
      ''');
    } else {
      print('Results table already exists.');
    }

    print('Database schema ensured.');
  }

  Future<bool> registerUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': _hashPassword(password),
      });
      print('User registered successfully: $username');
      return true;
    } catch (e) {
      print('Error registering user: $e');
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

  Future<List<Map<String, dynamic>>> getQuizzes() async {
    try {
      final db = await database;
      return await db.query('quizzes');
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions(int quizId) async {
    try {
      final db = await database;
      return await db.query(
        'questions',
        where: 'quizId = ?',
        whereArgs: [quizId],
      );
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  Future<void> saveResult(int userId, int quizId, int score, int totalQuestions) async {
    final db = await database;
    await db.insert('results', {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserResults(int userId, {int? quizId}) async {
    final db = await database;
    if (quizId != null) {
      return await db.query(
        'results',
        where: 'userId = ? AND quizId = ?',
        whereArgs: [userId, quizId],
        orderBy: 'date DESC',
      );
    }
    return await db.query(
      'results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getQuiz(int quizId) async {
    final db = await database;
    final result = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [quizId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future close() async {
    final db = await database;
    await db.close();
  }

  Future<void> clearUserResults(int userId, {int? quizId}) async {
    final db = await database;
    try {
      if (quizId != null) {
        await db.delete(
          'results',
          where: 'userId = ? AND quizId = ?',
          whereArgs: [userId, quizId],
        );
        print('Cleared results for userId: $userId, quizId: $quizId');
      } else {
        await db.delete(
          'results',
          where: 'userId = ?',
          whereArgs: [userId],
        );
        print('Cleared all results for userId: $userId');
      }
    } catch (e) {
      print('Error clearing results: $e');
    }
  }

}

