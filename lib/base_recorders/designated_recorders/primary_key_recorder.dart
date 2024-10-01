import 'package:dead_reckoning_song/base_recorders/designated_recorders/base_designated_recorder.dart';
import 'package:sqflite/sqflite.dart';

abstract class PrimaryKeyRecorder extends DesignatedRecorder {
  PrimaryKeyRecorder(super.updater);

  Function(Transaction) transactionInjector(String injectFields) {
    return (txn) async {
      return await txn.execute("""
      CREATE TABLE ${getTableName()} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        $injectFields
      );""");
    };
  }
}
