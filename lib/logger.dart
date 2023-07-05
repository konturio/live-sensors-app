import 'dart:async';

enum LogType { info, error, warning }

String humanReadableTypeName(LogType type) {
  switch (type) {
    case LogType.info:
      return "Info message";
    case LogType.error:
      return "Error message";
    case LogType.warning:
      return "Warning message";
  }
}

String humanReadableTimeStamp(DateTime date) {
  return '[${date.year}/${date.month}/${date.day}]: ${date.hour}:${date.minute}:${date.second}.${date.millisecond}';
}

class LogRecord {
  LogType type;
  String msg;
  DateTime _timestamp = DateTime.now();
  LogRecord(this.type, this.msg);

  get typeName {
    return humanReadableTypeName(type);
  }

  get time {
    return humanReadableTimeStamp(_timestamp);
  }
}

class Logger {
  // 10_000 must be enough for write logs 8 hours every 3 second
  // TODO: dump it to disk instead of keeping in memory
  int maxRecords;
  Logger({this.maxRecords = 10000}) {
    info('Logger started');
  }
  final List<LogRecord> _records = <LogRecord>[];
  final List<Function> _listeners = <Function>[];

  _add(LogRecord record) {
    if (_records.length > maxRecords) {
      _records.removeAt(0);
    }
    _records.add(record);
    _update();
  }

  _update() {
    for (final listener in _listeners) {
      listener(_records);
    }
  }

  info(String msg) {
    _add(LogRecord(LogType.info, msg));
  }

  warn(String msg) {
    _add(LogRecord(LogType.warning, msg));
  }

  error(String msg) {
    _add(LogRecord(LogType.error, msg));
  }

  Function subscribe(void Function(List<LogRecord>) listener) {
    _listeners.add(listener);
    Future(() => listener(_records));
    return () {
      _listeners.remove(listener);
    };
  }
}
