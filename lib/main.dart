import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/recorders_manager.dart';
import 'package:dead_reckoning_song/geoloc.dart' as geol;
import 'package:dead_reckoning_song/service.dart' as main_service;
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

String iso8601ToSQLITE(String iso8601) {
  var withoutZ = iso8601.substring(0, iso8601.length - 1);
  return withoutZ.split("T").join(" ");
}

void update_field(String measurement, Map<String, dynamic> fields, String time,
    {Map<String, dynamic>? tags}) {
  final combined = {
    ...{"datetime": time},
    ...fields,
    ...?tags,
  };
  database.insert(measurement, combined,
      conflictAlgorithm: ConflictAlgorithm.replace);
}

late Database database;
// late RecordersManager recordersManager;

late FlutterBackgroundService service;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // recordersManager = await RecordersManager.create('doggie_database.db');
  // print("Path: ${path.join(await getDatabasesPath(), 'doggie_database.db')}");
  // database = await openDatabase(
  //   // Set the path to the database. Note: Using the `join` function from the
  //   // `path` package is best practice to ensure the path is correctly
  //   // constructed for each platform.
  //   path.join(await getDatabasesPath(), 'doggie_database.db'),
  //   onCreate: (db, version) {
  //     return create(db, version);
  //   },
  //   onUpgrade: (db, oldVersion, newVersion) {
  //     var currentVersion = oldVersion;
  //     while (currentVersion < newVersion) {
  //       var upgradeFunction =
  //           versionPairToUpgradeFunction[(currentVersion, currentVersion + 1)];
  //       if (upgradeFunction == null) {
  //         throw UnimplementedError("Function isn't implemented!");
  //       }
  //       upgradeFunction(db, oldVersion, newVersion);
  //       currentVersion += 1;
  //     }
  //   },
  //   version: 1,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);
  int _counter = 0;
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

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
                onPressed: () async {
                  Share.shareXFiles([
                    XFile(path.join(
                        await getDatabasesPath(), 'doggie_database.db'))
                  ]);
                },
                child: Text('Share file')),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    record = !record;
                  });
                },
                child: Text('${record ? "Stop" : "Start"} recording data')),
            ElevatedButton(
              child: const Text("Request permissions"),
              onPressed: () async {
                var result = await geol.handlePermission();
                if (!result) {
                  return;
                }
                var notificationPermissionStatus =
                    await Permission.notification.request();
                if (!notificationPermissionStatus.isGranted) {
                  return;
                }
                bool? isBatteryOptimizationDisabled =
                    await DisableBatteryOptimization
                        .isBatteryOptimizationDisabled;
                if (isBatteryOptimizationDisabled != true) {
                  var batteryOptimizationResult =
                      await DisableBatteryOptimization
                          .showDisableBatteryOptimizationSettings();
                  if (batteryOptimizationResult != true) {
                    return;
                  }
                }

                bool? isManBatteryOptimizationDisabled = await DisableBatteryOptimization.isManufacturerBatteryOptimizationDisabled;
                if(isManBatteryOptimizationDisabled != true) {
                  await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings("Your device has additional battery optimization", "Follow the steps and disable the optimizations to allow smooth functioning of this app");
                }
                service = await main_service.initializeService();
                // service.invoke("approved");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    // _getCurrentPosition().then((_) {
    //   _toggleListening();
    // });
    // subscribe();
  }

  /*void subscribe() {
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (UserAccelerometerEvent event) {
          final now = event.timestamp;
          if (record) {
            recordersManager.userAccelerometerRecorder
                .insert(event.timestamp, event.x, event.y, event.z);
          }
          setState(() {
            _userAccelerometerEvent = event;
            if (_userAccelerometerUpdateTime != null) {
              final interval = now.difference(_userAccelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _userAccelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support User Accelerometer Sensor"),
                );
              });
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
          setState(() {
            _accelerometerEvent = event;
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Accelerometer Sensor"),
                );
              });
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
          setState(() {
            _gyroscopeEvent = event;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Gyroscope Sensor"),
                );
              });
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
          setState(() {
            _magnetometerEvent = event;
            if (_magnetometerUpdateTime != null) {
              final interval = now.difference(_magnetometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _magnetometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Magnetometer Sensor"),
                );
              });
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
          setState(() {
            _barometerEvent = event;
            if (_barometerUpdateTime != null) {
              final interval = now.difference(_barometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _barometerLastInterval = interval.inMilliseconds;
              }
            }
          });
          _barometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Barometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
  }*/

/*  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    // _updatePositionList(
    //   _PositionItemType.position,
    //   position.toString(),
    // );
    if (record) {
      recordersManager.gpsRecorder.insert(
        position.timestamp,
        position.accuracy,
        position.latitude,
        position.longitude,
        position.altitudeAccuracy,
        position.heading,
        position.headingAccuracy,
        position.speed,
        position.speedAccuracy,
      );
    }
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // _updatePositionList(
      //   _PositionItemType.log,
      //   _kLocationServicesDisabledMessage,
      // );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // _updatePositionList(
        //   _PositionItemType.log,
        //   _kPermissionDeniedMessage,
        // );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // _updatePositionList(
      //   _PositionItemType.log,
      //   _kPermissionDeniedForeverMessage,
      // );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // _updatePositionList(
    //   _PositionItemType.log,
    //   _kPermissionGrantedMessage,
    // );
    return true;
  }

  StreamSubscription<Position>? _positionStreamSubscription;
  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        // _positionStreamSubscription?.cancel();
        // _positionStreamSubscription = null;
      }).listen((position) {
        if (record) {
          recordersManager.gpsRecorder.insert(
            position.timestamp,
            position.accuracy,
            position.latitude,
            position.longitude,
            position.altitudeAccuracy,
            position.heading,
            position.headingAccuracy,
            position.speed,
            position.speedAccuracy,
          );
        }
      });
      // _positionStreamSubscription?.pause();
    }

    // setState(() {
    //   if (_positionStreamSubscription == null) {
    //     return;
    //   }

    //   String statusDisplayValue;
    //   if (_positionStreamSubscription!.isPaused) {
    //     _positionStreamSubscription!.resume();
    //     statusDisplayValue = 'resumed';
    //   } else {
    //     _positionStreamSubscription!.pause();
    //     statusDisplayValue = 'paused';
    //   }

    //   _updatePositionList(
    //     _PositionItemType.log,
    //     'Listening for position updates $statusDisplayValue',
    //   );
    // });
  }*/
}
