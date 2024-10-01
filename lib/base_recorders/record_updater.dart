import 'dart:collection';

import 'package:sqflite/sqflite.dart';

class Entry {
  Entry(this.measurement, this.fields);
  String measurement;
  Map<String, dynamic> fields;
}

class RecordUpdater {
  late final Database database;
  RecordUpdater(this.database, {this.maxConcurrentTasks = 1});

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

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _input.isEmpty) {
      return;
    }

    while (_input.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      print('Concurrent workers: $runningTasks');
      database.transaction((txn) async {
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
      }).then((_) {
        runningTasks--;
      });
    }
  }

  void update_field(String measurement, Map<String, dynamic> fields,
      {Map<String, dynamic>? tags}) {
    final combined = {
      ...fields,
      ...?tags,
    };
    // database.insert(measurement, combined,
    //     conflictAlgorithm: ConflictAlgorithm.replace);
    add(Entry(measurement, combined));
  }
}
