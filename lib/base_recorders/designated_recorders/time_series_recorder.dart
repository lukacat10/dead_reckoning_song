import 'package:dead_reckoning_song/base_recorders/designated_recorders/primary_key_recorder.dart';
import 'package:sqflite/sqflite.dart';

abstract class TimeSeriesRecorder extends PrimaryKeyRecorder {
  TimeSeriesRecorder(super.updater);

  String iso8601ToSQLITE(String iso8601) {
    var withoutZ = iso8601.substring(0, iso8601.length - 1);
    return withoutZ.split("T").join(" ");
  }

  String DatetimeToSQLITE(DateTime time) {
    return iso8601ToSQLITE(time.toIso8601String());
  }

  @override
  Function(Transaction) transactionInjector(String injectFields) {
    return (txn) async {
      var transactionFunction = super
          .transactionInjector("datetime DATETIME NOT NULL,\n$injectFields");

      await transactionFunction(txn);

      return await txn.execute("""
        CREATE INDEX idx_${getTableName()}_datetime ON ${getTableName()}(datetime);
      """);
    };
  }
}
