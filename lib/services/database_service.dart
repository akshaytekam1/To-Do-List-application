import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  // setup database
  Future<Database> getDatabase() async {
    final databasesDirPath = await getDatabasesPath();
    final databasePath = join(databasesDirPath, "master_db.db");

    //Delete old DB to force table recreation
    // await deleteDatabase(databasePath);

    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_tasksTableName (
          $_tasksIdColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
          $_tasksContentColumnName TEXT NOT NULL,
          $_tasksStatusColumnName INTEGER NOT NULL
        )
      ''');
      },
    );

    return database;
  }

  // add task code
  void addTask(String content) async {
    final db = await database;
    await db.insert(_tasksTableName, {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  // get all task data from database and convert to list for reading and showing data
  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    // print(data);
    List<Task> tasks =
        data
            .map(
              (e) => Task(
                id: e["id"] as int,
                status: e["status"] as int,
                content: e["content"] as String,
              ),
            )
            .toList();
    return tasks;
  }

  // update single task status from database
  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {_tasksStatusColumnName: status},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // delete single task from database
  void deleteTask(int id) async {
    final db = await database;
    await db.delete(_tasksTableName, where: "id = ?", whereArgs: [id]);
  }
}
