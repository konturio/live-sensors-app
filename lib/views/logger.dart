import 'package:flutter/material.dart';
import 'package:live_sensors/logger.dart';

class LoggerView extends StatefulWidget {
  final Logger logger;
  const LoggerView({super.key, required this.logger});

  @override
  State<LoggerView> createState() => _LoggerViewState();
}

class _LoggerViewState extends State<LoggerView> {
  List<LogRecord> _records = <LogRecord>[];
  late Function _unsubscribe;

  @override
  initState() {
    super.initState();
    _unsubscribe = widget.logger.subscribe((records) {
      setState(() {
        _records = records;
      });
    });
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _records
          .map(
            (log) => Card(
              child: ListTile(
                title: Text(log.msg),
                subtitle: Text(log.time),
              ),
            ),
          )
          .toList(),
    );
  }
}
