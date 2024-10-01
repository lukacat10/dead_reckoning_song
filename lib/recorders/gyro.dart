import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/designated_recorders/xyz_recorder.dart';

class GyroRecorder extends XYZRecorder {
  GyroRecorder(super.updater);

  @override
  String getTableName() {
    return "gyro";
  }

  @override
  Map<(int, int), FutureOr<void> Function(int p1, int p2)> getUpgraders() {
    return {
      (1,2): emptyUpgrader
    };
  }

}
