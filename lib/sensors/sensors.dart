import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:live_sensors/logger/logger.dart';


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
  late Stream<SensorsData> stream;

  Sensors() {
    final controller = StreamController<SensorsData>.broadcast();

    SensorEvent<UserAccelerometerEvent>? accel;
    SensorEvent<GyroscopeEvent>? gyro;
    SensorEvent<MagnetometerEvent>? magnet;

    void emit() {
      if (accel != null && gyro != null && magnet != null) {
        controller.add((accel!, gyro!, magnet!));
      }
    }

    userAccelerometerEvents.listen((event) {
      accel = SensorEvent(event, DateTime.now());
      emit();
    });

    gyroscopeEvents.listen((event) {
      gyro = SensorEvent(event, DateTime.now());
      emit();
    });

    magnetometerEvents.listen((event) {
      magnet = SensorEvent(event, DateTime.now());
      emit();
    });

    stream = controller.stream;
  }
}
