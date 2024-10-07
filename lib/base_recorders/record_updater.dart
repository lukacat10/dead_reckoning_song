import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

class Entry {
  Entry(this.measurement, this.fields);
  String measurement;
  Map<String, dynamic> fields;
}

class RecordUpdater {
  String dbpath;
  Database? _database;

  Future<bool> _dbFileExists() async {
    return await File(dbpath).exists();
  }

  Future<Database> getDatabase() async {
    if (await _dbFileExists() && _database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      dbpath,
      onCreate: (db, version) async {
        var futures = [
          for (var future in _onCreateListeners) future(db, version)
        ];
        await Future.wait(futures);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var futures = [
          for (var future in _onUpgradeListeners)
            future(db, oldVersion, newVersion)
        ];
        await Future.wait(futures);
      },
      version: 2,
    );

    return _database!;
  }

  final List<Future<void> Function(Database db, int version)>
      _onCreateListeners = [];

  Future<void> onCreate(
      Future<void> Function(Database db, int version) a) async {
    _onCreateListeners.add(a);
  }

  final List<Future<void> Function(Database db, int oldVersion, int newVersion)>
      _onUpgradeListeners = [];

  Future<void> onUpgrade(
      Future<void> Function(Database db, int oldVersion, int newVersion)
          a) async {
    _onUpgradeListeners.add(a);
  }

  RecordUpdater(this.dbpath, {this.maxConcurrentTasks = 1});

  final Queue<Entry> _input = Queue();
  final int maxConcurrentTasks;
  int runningTasks = 0;

  void add(Entry value) {
    _input.add(value);
    _startExecution();
  }

  void addAll(Iterable<Entry> iterable) {
    _input.addAll(iterable);
    _startExecution();
  }

  void _startExecution() {
    // Ensures only one batch insert is being made.
    if (runningTasks == maxConcurrentTasks || _input.isEmpty) {
      return;
    }

    while (_input.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      print('Concurrent workers: $runningTasks');
      getDatabase().then((db) {
        return db.transaction((txn) async {
          var batch = txn.batch();
          while (_input.isNotEmpty) {
            var entry = _input.removeFirst();
            try {
              batch.insert(entry.measurement, entry.fields,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            } catch (exception) {
              throw "some error while insertion";
            }
          }

          await batch.commit(continueOnError: false, noResult: true);
        });
      }).then((_) {
        runningTasks--;
      });
    }
  }

  void update_field(String measurement, Map<String, dynamic> fields,
      {Map<String, dynamic>? tags}) async {
    final combined = {
      ...fields,
      ...?tags,
    };
    // database.insert(measurement, combined,
    //     conflictAlgorithm: ConflictAlgorithm.replace);
    add(Entry(measurement, combined));
  }
}
