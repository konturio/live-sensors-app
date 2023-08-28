import 'dart:async';
import 'package:statistics/statistics.dart';

class CallPerSecMeasure {
  num _counter = 0;
  num _maxHistLength = 0;
  final List<num> _history = <num>[];

  CallPerSecMeasure({ num maxHistoryLength = 5 }) {
    _maxHistLength = maxHistoryLength;

    /// Remember how many ticks was during last second 
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _add(_counter);
      _counter = 0;
    });
  }

  num get mean {
   return _history.mean;
  }

  _add(record) {
    if (_history.length > _maxHistLength) {
      _history.removeAt(0);
    }
    _history.add(record);
  }

  tick() {
    _counter += 1;
  }
}