import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dead_reckoning_song/base_recorders/record_updater.dart';
import 'package:dead_reckoning_song/base_recorders/recorders_manager.dart';
import 'package:dead_reckoning_song/geoloc.dart';
import 'package:dead_reckoning_song/sensors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<FlutterBackgroundService> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
  );

  return service;
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

late Geoloc geoloc;
late Sensors sensors;

Future<String> dbpath() async {
  return path.join(await getDatabasesPath(), 'doggie_database.db');
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // final socket = io.io("your-server-url", <String, dynamic>{
  //   'transports': ['websocket'],
  //   'autoConnect': true,
  // });
  // socket.onConnect((_) {
  //   print('Connected. Socket ID: ${socket.id}');
  //   // Implement your socket logic here
  //   // For example, you can listen for events or send data
  // });

  // socket.onDisconnect((_) {
  //   print('Disconnected');
  // });
  //  socket.on("event-name", (data) {
  //   //do something here like pushing a notification
  // });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    // service.on('setAsBackground').listen((event) {
    //   service.setAsBackgroundService();
    // });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
    print("foreground process is now stopped");
  });

  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {});

  RecordersManager recordersManager =
      RecordersManager(RecordUpdater(await dbpath()));
  geoloc = Geoloc(recordersManager);
  geoloc.record = true;
  // service.on("approved").listen((event) {
  geoloc.getCurrentPosition().then((_) {
    geoloc.toggleListening();
  });
  // });

  sensors = Sensors(recordersManager);
  sensors.record = true;
  sensors.subscribe();

  // Timer.periodic(const Duration(seconds: 1), (timer) {
  //   socket.emit("event-name", "your-message");
  //   print("service is successfully running ${DateTime.now().second}");
  // });

  // service.invoke("init_success");

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      //if (await service.isForegroundService()) {
      /// OPTIONAL for use custom notification
      /// the notification id must be equals with AndroidConfiguration when you call configure() method.
      // flutterLocalNotificationsPlugin.show(
      //   888,
      //   'COOL SERVICE',
      //   'Awesome ${DateTime.now()}',
      //   const NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       'my_foreground',
      //       'MY FOREGROUND SERVICE',
      //       icon: 'ic_bg_service_small',
      //       ongoing: true,
      //     ),
      //   ),
      // );

      // if you don't using custom notification, uncomment this
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
      //}
    }

    /// you can see this log in logcat
    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    // final deviceInfo = DeviceInfoPlugin();
    // String? device;
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   device = androidInfo.model;
    // } else if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   device = iosInfo.model;
    // }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "wo",
      },
    );
  });
}
