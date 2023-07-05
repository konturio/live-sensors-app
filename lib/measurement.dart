import 'package:sensors_plus/sensors_plus.dart';
import 'sensors.dart';

typedef Measurement = (
  SensorEvent<UserAccelerometerEvent>,
  SensorEvent<GyroscopeEvent>,
  SensorEvent<MagnetometerEvent>,
);

