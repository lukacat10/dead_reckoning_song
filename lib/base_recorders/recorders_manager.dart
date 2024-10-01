import 'package:dead_reckoning_song/base_recorders/record_updater.dart';
import 'package:dead_reckoning_song/base_recorders/recorder.dart';
import 'package:dead_reckoning_song/recorders/accelerometer.dart';
import 'package:dead_reckoning_song/recorders/barometer.dart';
import 'package:dead_reckoning_song/recorders/gps.dart';
import 'package:dead_reckoning_song/recorders/gyro.dart';
import 'package:dead_reckoning_song/recorders/magnetometer.dart';
import 'package:dead_reckoning_song/recorders/user_accelerometer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class RecordersManager {
  RecordersManager(this.updater)
      : accelerometerRecorder = AccelerometerRecorder(updater),
        userAccelerometerRecorder = UserAccelerometerRecorder(updater),
        gyroRecorder = GyroRecorder(updater),
        magnetometerRecorder = MagnetometerRecorder(updater),
        barometerRecorder = BarometerRecorder(updater),
        gpsRecorder = GPSRecorder(updater);

  RecordUpdater updater;

  AccelerometerRecorder accelerometerRecorder;
  UserAccelerometerRecorder userAccelerometerRecorder;
  GyroRecorder gyroRecorder;
  MagnetometerRecorder magnetometerRecorder;
  BarometerRecorder barometerRecorder;
  GPSRecorder gpsRecorder;

  List<Recorder> getRecorders() {
    return List.unmodifiable([
      accelerometerRecorder,
      userAccelerometerRecorder,
      gyroRecorder,
      magnetometerRecorder,
      barometerRecorder,
      gpsRecorder,
    ]);
  }

  static Future<RecordersManager> create(String dbFileName) async {
    RecordersManager? manager;
    Database db = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      path.join(await getDatabasesPath(), dbFileName),
      onCreate: (db, version) async {
        manager ??= RecordersManager(RecordUpdater(db));
        // manager!.getRecorders().map((rec) async => await rec.onCreate());
        for (var rec in manager!.getRecorders()) {
          await rec.onCreate();
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        manager ??= RecordersManager(RecordUpdater(db));
        for (var rec in manager!.getRecorders()) {
          await rec.runUpgraders(oldVersion, newVersion);
        }
      },
      version: 2,
    );
    manager ??= RecordersManager(RecordUpdater(db));
    return manager!;
  }
}
