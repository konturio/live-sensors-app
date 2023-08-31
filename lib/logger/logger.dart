import 'dart:async';
import 'package:flutter_logs/flutter_logs.dart';

enum LogType { info, error, warning }

String _humanReadableTypeName(LogType type) {
  switch (type) {
    case LogType.info:
      return "Info message";
    case LogType.error:
      return "Error message";
    case LogType.warning:
      return "Warning message";
  }
}

String _humanReadableTimeStamp(DateTime date) {
  return '[${date.year}/${date.month}/${date.day}]: ${date.hour}:${date.minute}:${date.second}.${date.millisecond}';
}

class LogRecord {
  final DateTime _timestamp = DateTime.now();
  LogType type;
  String msg;
  LogRecord(this.type, this.msg);

  get typeName {
    return _humanReadableTypeName(type);
  }

  get time {
    return _humanReadableTimeStamp(_timestamp);
  }
}

class Logger {
  // 10_000 must be enough for write logs 8 hours every 3 second
  int maxRecords = 10000;
  final tag = 'live_sensors';

  // Singleton
  static final Logger _singleton = Logger._internal();
  factory Logger() => _singleton;
  Logger._internal();

  init() async {
    //Initialize Logging
    // await FlutterLogs.initLogs(
    //   logLevelsEnabled: [
    //     LogLevel.INFO,
    //     LogLevel.WARNING,
    //     LogLevel.ERROR,
    //     LogLevel.SEVERE
    //   ],
    //   timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
    //   directoryStructure: DirectoryStructure.FOR_DATE,
    //   logTypesEnabled: ["device", "network", "errors"],
    //   logFileExtension: LogFileExtension.LOG,
    //   logsWriteDirectoryName: "MyLogs",
    //   logsExportDirectoryName: "MyLogs/Exported",
    //   debugFileOperations: true,
    //   isDebuggable: true,
    // );
    await FlutterLogs.initMQTT(
      writeLogsToLocalStorage: false,
      topic: "live-sensor-app",
      brokerUrl: "zigzag.kontur.io", // Add URL without schema
      // certificate: "m2mqtt_ca.crt",
      port: "1883",
    );
    await FlutterLogs.setMetaInfo(
      appId: "flutter_logs_example",
      appName: "Flutter Logs Demo",
      appVersion: "1.0",
      // language: "",
      // deviceId: "",
      // environmentId: "",
      // environmentName: "",
      // organizationId: "",
      // userId: tokens.sessionId
      // userName: "",
      // userEmail: "",
      // deviceSerial: "",
      // deviceBrand: "",
      // deviceName: "",
      // deviceManufacturer: "",
      // deviceModel: "",
      // deviceSdkInt: "",
    );
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

  info(String msg, [String subTag = 'default']) {
    FlutterLogs.logInfo(tag, subTag, msg);
    _add(LogRecord(LogType.info, msg));
  }

  warn(String msg, [String subTag = 'default']) {
    FlutterLogs.logWarn(tag, subTag, msg);
    _add(LogRecord(LogType.warning, msg));
  }

  error(String msg, [String subTag = 'default']) {
    FlutterLogs.logError(tag, subTag, msg);
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
