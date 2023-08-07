import 'package:sensors_plus/sensors_plus.dart';
import 'package:async/async.dart';
import 'dart:async';

import 'logger.dart';

typedef SensorsData = (
  SensorEvent<UserAccelerometerEvent>,
  SensorEvent<GyroscopeEvent>,
  SensorEvent<MagnetometerEvent>,
);

class SensorEvent<T> {
  late DateTime timestamp = DateTime.now();
  final T data;
  SensorEvent(this.data, this.timestamp);
}

class Sensors {
  final Logger logger = Logger();
  final List<Stream> _sensors = <Stream>[
    userAccelerometerEvents.map((event) => SensorEvent(event, DateTime.now())),
    gyroscopeEvents.map((event) => SensorEvent(event, DateTime.now())),
    magnetometerEvents.map((event) => SensorEvent(event, DateTime.now()))
  ];
  late Stream<SensorsData> stream;

  Sensors() {
    stream = StreamZip(_sensors).map((List event) => (
          event[0],
          event[1],
          event[2],
        ));
  }
}
