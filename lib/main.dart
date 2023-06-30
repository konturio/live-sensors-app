import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'ask_permission.dart';
import 'logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live sensors',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Live sensors'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Logger logger = Logger();
  List<LogRecord> _records = <LogRecord>[];

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  _HomePageState() {
    logger.subscribe((records) {
      setState(() {
        _records = records;
      });
    });
  }

  bool _traking = false;
  _initTrackPosition() async {
    try {
      logger.info('Requesting permissions');
      Position position = await requestLocationPermission();
      logger.info("Permission granted");
      logger.info("Position changed: ${position.toString()}");
      logger.info("Create position steam");
      // TODO: listen position service status too
      Stream<Position> positionStream = Geolocator.getPositionStream();
      setState(() {
        _traking = true;
      });
      _positionStreamSubscription = positionStream.handleError((error) {
        setState(() {
          _traking = false;
          logger.error(error.toString());
        });
      }).listen((position) {
        logger.info("Position changed: ${position.toString()}");
      });
    } catch (error) {
      setState(() {
        _traking = false;
        logger.error(error.toString());
      });
    }
  }

  _toggleTrackPosition() {
    if (_positionStreamSubscription == null) {
      _initTrackPosition();
    } else if (_traking) {
      _positionStreamSubscription?.pause();
      setState(() {
        _traking = false;
      });
    } else {
      _positionStreamSubscription?.resume();
      setState(() {
        _traking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
          children: _records
              .map((log) => Card(
                      child: ListTile(
                    title: Text(log.msg),
                    subtitle: Text(log.time),
                  )))
              .toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTrackPosition,
        tooltip: 'Show position',
        child:
            _traking ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
