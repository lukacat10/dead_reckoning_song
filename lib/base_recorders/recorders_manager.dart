import 'package:dead_reckoning_song/base_recorders/record_updater.dart';
import 'package:dead_reckoning_song/recorders/accelerometer.dart';
import 'package:dead_reckoning_song/recorders/barometer.dart';
import 'package:dead_reckoning_song/recorders/gps.dart';
import 'package:dead_reckoning_song/recorders/gyro.dart';
import 'package:dead_reckoning_song/recorders/magnetometer.dart';
import 'package:dead_reckoning_song/recorders/user_accelerometer.dart';

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
}
