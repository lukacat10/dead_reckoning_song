import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/record_updater.dart';

abstract class Recorder {
  late final RecordUpdater updater;
  Recorder(this.updater) {
    updater.onCreate(
      (db, version) async {
        return await onCreate();
      },
    );
    updater.onUpgrade(
      (db, oldVersion, newVersion) async {
        return await runUpgraders(oldVersion, newVersion);
      },
    );
  }

  String getTableName();

  Future<void> onCreate();

  Map<(int, int), FutureOr<void> Function(int, int)> getUpgraders();

  FutureOr<void> emptyUpgrader(int oldVersion, int newVersion) {}

  FutureOr<void> runUpgraders(int oldVersion, int newVersion) {
    var currentVersion = oldVersion;
    while (currentVersion < newVersion) {
      var upgradeFunction =
          getUpgraders()[(currentVersion, currentVersion + 1)];
      if (upgradeFunction == null) {
        throw UnimplementedError(
            "Upgrade function from version $oldVersion to $newVersion isn't implemented!");
      }
      upgradeFunction(oldVersion, newVersion);
      currentVersion += 1;
    }
  }

  void insertFields(Map<String, dynamic> fields) {
    return updater.update_field(getTableName(), fields);
  }
}
