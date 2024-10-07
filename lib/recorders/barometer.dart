import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/designated_recorders/time_series_recorder.dart';
import 'package:dead_reckoning_song/base_recorders/recorder.dart';

class BarometerRecorder extends TimeSeriesRecorder {
  BarometerRecorder(super.updater);

  @override
  String getTableName() {
    return "barometer";
  }

  @override
  Map<(int, int), FutureOr<void> Function(int p1, int p2)> getUpgraders() {
    return {
      (1,2): emptyUpgrader
    };
  }

  @override
  Future<void> onCreate() {
    return onCreateWithFields("""pressure REAL""");
  }

  void insert(DateTime time, double pressure) {
    // TODO: implement insert
    super.insertFields({
      "datetime": DatetimeToSQLITE(time),
      "pressure": pressure
    });
  }

}
