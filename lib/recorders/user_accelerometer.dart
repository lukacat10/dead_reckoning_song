import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/designated_recorders/xyz_recorder.dart';

class UserAccelerometerRecorder extends XYZRecorder {
  UserAccelerometerRecorder(super.updater);

  @override
  String getTableName() {
    return "user_accelerometer";
  }

  @override
  Map<(int, int), FutureOr<void> Function(int p1, int p2)> getUpgraders() {
    return {
      (1,2): emptyUpgrader
    };
  }

}
