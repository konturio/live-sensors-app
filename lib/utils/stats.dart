import 'dart:async';
import 'package:statistics/statistics.dart';

class CallPerSecMeasure {
  num _counter = 0;
  num _histLength = 0;
  final List<num> _history = <num>[];
  late Duration updateStatsFrequency;
  num mean = 0;

  CallPerSecMeasure({ num? historyLength, Duration? updateStatsFrequency }) {
    _histLength = historyLength ?? 20;
    this.updateStatsFrequency = updateStatsFrequency ?? const Duration(seconds: 5);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      _add(_counter);
      _counter = 0;
    });

    Timer.periodic(this.updateStatsFrequency, (timer) {
      mean = _history.mean;
    });
  }

  _add(record) {
    if (_history.length > _histLength) {
      _history.removeAt(0);
    }
    _history.add(record);
  }

  tick() {
    _counter += 1;
  }
}