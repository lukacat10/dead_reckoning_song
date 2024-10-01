import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/designated_recorders/time_series_recorder.dart';
import 'package:dead_reckoning_song/base_recorders/recorder.dart';

class GPSRecorder extends TimeSeriesRecorder {
  GPSRecorder(super.updater);

  @override
  String getTableName() {
    return "gps";
  }

  @override
  Map<(int, int), FutureOr<void> Function(int oldVersion, int newVersion)>
      getUpgraders() {
    return {(1, 2): (oldVer, newVer) => onCreate()};
  }

  @override
  FutureOr<void> onCreate() {
    return onCreateWithFields("""accuracy REAL,
latitude REAL,
longitude REAL,
altitudeAccuracy REAL,
heading REAL,
headingAccuracy REAL,
speed REAL,
speedAccuracy REAL""");
  }

  void insert(
    DateTime time,
    double accuracy,
    double latitude,
    double longitude,
    double altitudeAccuracy,
    double heading,
    double headingAccuracy,
    double speed,
    double speedAccuracy,
  ) {
    super.insertFields({
      "datetime": DatetimeToSQLITE(time),
      "accuracy": accuracy,
      "latitude": latitude,
      "longitude": longitude,
      "altitudeAccuracy": altitudeAccuracy,
      "heading": heading,
      "headingAccuracy": headingAccuracy,
      "speed": speed,
      "speedAccuracy": speedAccuracy,
    });
  }
}
