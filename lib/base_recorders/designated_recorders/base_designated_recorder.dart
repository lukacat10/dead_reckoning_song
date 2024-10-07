import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/recorder.dart';
import 'package:sqflite/sqflite.dart';

abstract class DesignatedRecorder extends Recorder {
  DesignatedRecorder(super.updater);

  Function(Transaction) transactionInjector(String injectFields);

  Future<void> onCreateWithFields(String injectFields) async {
    var transactionFunction = transactionInjector(injectFields);
    var db = await updater.getDatabase();
    return db.transaction((txn) async {
      await transactionFunction(txn);
    });
  }
}
