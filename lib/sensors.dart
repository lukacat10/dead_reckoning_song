import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/recorders_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Sensors {
  Sensors(this.recordersManager);
  RecordersManager recordersManager;

  bool record = false;

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;
  BarometerEvent? _barometerEvent;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  DateTime? _barometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  int? _barometerLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.fastestInterval;

  void subscribe() {
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          final now = event.timestamp;
          if (record) {
            recordersManager.userAccelerometerRecorder
                .insert(event.timestamp, event.x, event.y, event.z);
          }
          // setState(() {
          //   _userAccelerometerEvent = event;
          //   if (_userAccelerometerUpdateTime != null) {
          //     final interval = now.difference(_userAccelerometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _userAccelerometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return const AlertDialog(
          //         title: Text("Sensor Not Found"),
          //         content: Text(
          //             "It seems that your device doesn't support User Accelerometer Sensor"),
          //       );
          //     });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (AccelerometerEvent event) {
          if (record) {
            recordersManager.accelerometerRecorder
                .insert(event.timestamp, event.x, event.y, event.z);
          }
          final now = event.timestamp;
          // setState(() {
          //   _accelerometerEvent = event;
          //   if (_accelerometerUpdateTime != null) {
          //     final interval = now.difference(_accelerometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _accelerometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return const AlertDialog(
          //         title: Text("Sensor Not Found"),
          //         content: Text(
          //             "It seems that your device doesn't support Accelerometer Sensor"),
          //       );
          //     });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (GyroscopeEvent event) {
          if (record) {
            recordersManager.gyroRecorder
                .insert(event.timestamp, event.x, event.y, event.z);
          }
          final now = event.timestamp;
          // setState(() {
          //   _gyroscopeEvent = event;
          //   if (_gyroscopeUpdateTime != null) {
          //     final interval = now.difference(_gyroscopeUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _gyroscopeLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return const AlertDialog(
          //         title: Text("Sensor Not Found"),
          //         content: Text(
          //             "It seems that your device doesn't support Gyroscope Sensor"),
          //       );
          //     });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (MagnetometerEvent event) {
          final now = event.timestamp;
          if (record) {
            recordersManager.magnetometerRecorder
                .insert(event.timestamp, event.x, event.y, event.z);
          }
          // setState(() {
          //   _magnetometerEvent = event;
          //   if (_magnetometerUpdateTime != null) {
          //     final interval = now.difference(_magnetometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _magnetometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return const AlertDialog(
          //         title: Text("Sensor Not Found"),
          //         content: Text(
          //             "It seems that your device doesn't support Magnetometer Sensor"),
          //       );
          //     });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (BarometerEvent event) {
          final now = event.timestamp;
          if (record) {
            recordersManager.barometerRecorder
                .insert(event.timestamp, event.pressure);
          }
          // setState(() {
          //   _barometerEvent = event;
          //   if (_barometerUpdateTime != null) {
          //     final interval = now.difference(_barometerUpdateTime!);
          //     if (interval > _ignoreDuration) {
          //       _barometerLastInterval = interval.inMilliseconds;
          //     }
          //   }
          // });
          _barometerUpdateTime = now;
        },
        onError: (e) {
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //       return const AlertDialog(
          //         title: Text("Sensor Not Found"),
          //         content: Text(
          //             "It seems that your device doesn't support Barometer Sensor"),
          //       );
          //     });
        },
        cancelOnError: true,
      ),
    );
  }


}
