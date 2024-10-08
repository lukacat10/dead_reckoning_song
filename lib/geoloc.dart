import 'dart:async';

import 'package:dead_reckoning_song/base_recorders/recorders_manager.dart';
import 'package:geolocator/geolocator.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
Future<LocationPermission> checkPermission() async {
  return await _geolocatorPlatform.checkPermission();
}

Future<bool> handlePermission() async {
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

class Geoloc {
  Geoloc(this.recordersManager);
  RecordersManager recordersManager;
  bool record = false;

  Future<void> getCurrentPosition() async {
    final hasPermission = await handlePermission();

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

  StreamSubscription<Position>? _positionStreamSubscription;
  void toggleListening() {
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
  }
}
