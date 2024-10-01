import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/recorder.dart';
import 'package:sqflite/sqflite.dart';

abstract class DesignatedRecorder extends Recorder {
  DesignatedRecorder(super.updater);

  Function(Transaction) transactionInjector(String injectFields);

  FutureOr<void> onCreateWithFields(String injectFields) {
    var transactionFunction = transactionInjector(injectFields);

    return updater.database.transaction((txn) async {
      await transactionFunction(txn);
    });
  }
}
