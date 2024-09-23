import 'dart:async';
import 'package:sqflite/sqflite.dart';

final versionPairToUpgradeFunction = {
  // (1, 2): from_1_to_2,
};

FutureOr<void> create(Database db, int newVersion) {
  return db.transaction((txn) async {
    // Create User Accelerometer Table
    await txn.execute("""
      CREATE TABLE user_accelerometer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime DATETIME NOT NULL,
        x REAL,
        y REAL,
        z REAL
      );""");
    await txn.execute("""
      CREATE INDEX idx_user_accelerometer_datetime ON user_accelerometer(datetime);
    """);

    // Create Accelerometer Table
    await txn.execute("""
      CREATE TABLE accelerometer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime DATETIME NOT NULL,
        x REAL,
        y REAL,
        z REAL
      );""");

    // Create Accelerometer Table
    await txn.execute("""
      CREATE INDEX idx_accelerometer_datetime ON accelerometer(datetime);
    """);

    // Create Gyroscope Table
    await txn.execute("""
      CREATE TABLE gyro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime DATETIME NOT NULL,
        x REAL,
        y REAL,
        z REAL
      );""");

    // Create Gyroscope Table
    await txn.execute("""
      CREATE INDEX idx_gyro_datetime ON gyro(datetime);
    """);

    // Create Magnetometer Table
    await txn.execute("""
      CREATE TABLE magnetometer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime DATETIME NOT NULL,
        x REAL,
        y REAL,
        z REAL
      );""");

    await txn.execute("""
      CREATE INDEX idx_magnetometer_datetime ON magnetometer(datetime);
    """);

    // Create Barometer Table
    await txn.execute("""
      CREATE TABLE barometer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        datetime DATETIME NOT NULL,
        pressure REAL
      );""");

    // Create Barometer Table
    await txn.execute("""
      CREATE INDEX idx_barometer_datetime ON barometer(datetime);
    """);
  });
}
