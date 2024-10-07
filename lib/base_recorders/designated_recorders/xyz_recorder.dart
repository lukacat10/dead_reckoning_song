import 'dart:async';
import 'package:dead_reckoning_song/base_recorders/designated_recorders/time_series_recorder.dart';

abstract class XYZRecorder extends TimeSeriesRecorder {
  XYZRecorder(super.updater);

  @override
  Future<void> onCreate() {
    return onCreateWithFields("""x REAL,
        y REAL,
        z REAL""");
  }

  void insert(DateTime time, double x, double y, double z) {
    // TODO: implement insert
    super.insertFields({
      "datetime": DatetimeToSQLITE(time),
      "x": x,
      "y": y,
      "z": z,
    });
  }
}
